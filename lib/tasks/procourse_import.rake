# frozen_string_literal: true

require 'stripe'
require 'highline/import'

desc 'Import data from Procourse Memberships'
task 'subscriptions:procourse_import' => :environment do
  puts 'Begin task'
  setup_api
  puts 'Got Stripe key'
  products = get_stripe_prod
  puts 'Got products'
  products_to_import = []

  products.each do |product|
    confirm_import = ask("Do you wish to import product #{product[:name]} (id: #{product[:id]}): (y/N)")
    next if confirm_import.downcase != 'y'
    products_to_import << product
    print 'products_to_import:'
    puts products_to_import.join(", ")
  end

  import_prod(products_to_import)
  puts 'Done importing products'
  import_subs
end

def get_stripe_prod
  # todo needs paganation to get more than default 10
  puts 'Getting products from Stripe API'
  Stripe::Product.list
end

def import_prod(products)
  puts 'Importing products:'
  puts products.join(", ")
  products.each do |product|
    puts "Looking for external_id #{product[:id]}..."
    if DiscourseSubscriptions::Product.find_by(external_id: product[:id]).blank?
      ## DiscourseSubscriptions::Product.create(external_id: product[:id])
      puts "DiscourseSubscriptions::Product.create(external_id: #{product[:id]})"
    else
      puts "Product already exists"
    end
  end
end

def import_subs
  puts 'Importing subscriptions'
  product_ids = DiscourseSubscriptions::Product.all.pluck(:external_id)
  # todo needs paganation to get more than default 10
  customers = Stripe::Customer.list
  puts "customers first 5"
  puts customers.to_a[0..5]

  puts "customers :data first 5"
  puts customers[:data].to_a[0..5]

  # todo needs paganation to get more than default 10
  # todo only pull active subscriptions
  subscriptions = Stripe::Subscription.list
  subscriptions_for_products = subscriptions[:data].select { |sub| product_ids.include?(sub[:items][:data][0][:price][:product]) }

  subscriptions_for_products.each do |subscription|
    product_id = subscription[:items][:data][0][:price][:product]
    customer_id = subscription[:customer]
    subscription_id = subscription[:id]
    user_id = customers[:data].find(customer_id)[:description]

    if product_id && customer_id && subscription_id
      customer = DiscourseSubscriptions::Customer.find_by(user_id: user_id, customer_id: customer_id, product_id: product_id)

      if customer.nil? && user_id && user_id > 0
        # customer = DiscourseSubscriptions::Customer.create(
        #   user_id: user_id,
        #   customer_id: customer_id,
        #   product_id: product_id
        # )
        puts "customer = DiscourseSubscriptions::Customer.create(user_id: #{user_id}, customer_id: #{customer_id}, product_id: #{product_id})"
      end

      if customer
        if DiscourseSubscriptions::Subscription.find_by(customer_id: customer.id, external_id: subscription_id).blank?
          # DiscourseSubscriptions::Subscription.create(
          #   customer_id: customer.id,
          #   external_id: subscription_id
          # )
          puts "DiscourseSubscriptions::Subscription.create(customer_id: #{customer.id}, external_id: #{subscription_id})"
        end
      end
    end
  end
end

private

def setup_api
  api_key = SiteSetting.discourse_subscriptions_secret_key || ask('Input Stripe secret key')
  Stripe.api_key = api_key
end
