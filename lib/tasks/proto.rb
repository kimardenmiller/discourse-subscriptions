# frozen_string_literal: true

require 'stripe'
require 'highline/import'


def setup_api
  api_key = ENV["STRIPE_KEY"]
  Stripe.api_key = api_key
end

def get_procourse_stripe_products(starting_after:nil )
  puts 'Getting products from Stripe API'

  all_products = []

  loop do
    products = Stripe::Product.list({type: 'service', starting_after: starting_after, active: true })
    all_products += products[:data]

    break if products[:has_more] == false

    starting_after = products[:data].last["id"]

  end

  all_products

end

def get_procourse_stripe_subs(starting_after:nil )
  puts 'Getting Procourse Subscriptons from Stripe API'

  all_subscriptions = []

  loop do
    subscriptions = Stripe::Subscription.list({starting_after: starting_after, status: 'active'})

    all_subscriptions += subscriptions[:data]

    break if subscriptions[:has_more] == false

    starting_after = subscriptions[:data].last["id"]

  end

  all_subscriptions
end

def get_procourse_stripe_customers(starting_after:nil )
  puts 'Getting Procourse Customers from Stripe API'

  all_customers = []

  loop do
    customers = Stripe::Customer.list({starting_after: starting_after})

    all_customers += customers[:data]

    break if customers[:has_more] == false

    starting_after = customers[:data].last["id"]

  end

  all_customers
end

def import_procourse_products(products)
  puts 'Importing Procourse products'
  # puts products.join(", ")

  product_ids = []
  products.each do |product|
    puts "Adding for external_id #{product[:id]} ..."
    product_ids << product[:id]

    # if DiscourseSubscriptions::Product.find_by(external_id: product[:id]).blank?
      ## DiscourseSubscriptions::Product.create(external_id: product[:id])
      # puts "DiscourseSubscriptions::Product.create(external_id: #{product[:id]})"
    # else
    #   puts "Product already exists"
    # end
  end
  product_ids
end

def import_subscriptions(product_ids)
  puts 'Importing Procourse subscriptions'

  all_customers = get_procourse_stripe_customers
  puts 'Total available Stripe Customers: ' + all_customers.length.to_s
  puts "first customer id:" + all_customers[0][:description]

  all_subscriptions = get_procourse_stripe_subs
  puts 'Total Active Procourse Subscriptions available: ' + all_subscriptions.length.to_s

  subscriptions_for_products = all_subscriptions.select { |sub| product_ids.include?(sub[:items][:data][0][:price][:product]) }
  puts 'Total Subscriptions matching Products to Import: ' + subscriptions_for_products.length.to_s

  subscriptions_for_products.each do |subscription|
    product_id = subscription[:items][:data][0][:plan][:product]
    customer_id = subscription[:customer]
    subscription_id = subscription[:id]
    customer = all_customers.select { |cust| cust[:id] == customer_id }
    user_id = customer[0][:description].to_i

    if product_id && customer_id && subscription_id
      # puts product_id, customer_id, subscription_id, user_id
      # customer = DiscourseSubscriptions::Customer.find_by(user_id: user_id, customer_id: customer_id, product_id: product_id)

      # if customer.nil? && user_id && user_id > 0
        # customer = DiscourseSubscriptions::Customer.create(
        #   user_id: user_id,
        #   customer_id: customer_id,
        #   product_id: product_id
        # )
        # puts "customer = DiscourseSubscriptions::Customer.create(user_id: #{user_id}, customer_id: #{customer_id}, product_id: #{product_id})"
      # end

      # if customer
      #   if DiscourseSubscriptions::Subscription.find_by(customer_id: customer.id, external_id: subscription_id).blank?
          # DiscourseSubscriptions::Subscription.create(
          #   customer_id: customer.id,
          #   external_id: subscription_id
          # )
          # puts "DiscourseSubscriptions::Subscription.create(customer_id: #{customer.id}, external_id: #{subscription_id})"
        # end
      # end
    end
  end
end


setup_api

all_products = get_procourse_stripe_products
puts 'Total Active Procourse Products available: ' + all_products.length.to_s

products_to_import = []

all_products.each do |product|
  confirm_import = ask("Do you wish to import product #{product[:name]} (id: #{product[:id]}): (y/N)")
  next if confirm_import.downcase != 'y'
  products_to_import << product
end

product_ids = import_procourse_products(products_to_import)
import_subscriptions(product_ids)

# customers = Stripe::Customer.list
# puts "customers first 5"
# puts customers.to_a[0..1]
# puts customers

# puts "customers :data first 5"
# puts customers[:data].to_a[0..0]

# cust_ret = Stripe::Customer.retrieve('cus_J3PTQx9xS8HWnd')
# p "customer"
# p cust_ret[:description].to_i
# p cust_ret[:metadata]

# cust_data = customers[:data]
# p "customer id"
# puts cust_data[0][:description]

# cust_data.each do |customer|
  # p customer[:description].to_i
# end

# puts 'customer match'
# user_id = customers[:data].find('cus_J3PTQx9xS8HWnd')
# user_id = customers[:data].find('cus_J3PTQx9xS8HWnd')[:description]
# puts user_id

# subscriptions = Stripe::Subscription.list({status: 'active'})
# stripe_subs = subscriptions[:data]
# p stripe_subs.length
# puts stripe_subs[0][:customer]

# stripe_subs.each do |sub|
  # p sub[:customer]
  # p sub[:id]
# end

# sub_next = Stripe::Subscription.list({starting_after: 'sub_Ik6aQoaa7Bylwj'})

# sub_next.each do |sub|
  # p sub[:customer]
  # p sub[:id]
# end



# p 'all_subscriptions'
# all_subscriptions.each do |sub|
#   p sub[:id].to_s
# end




# puts product_ids.include?(all_subscriptions[0][:items][:data][0][:price][:product])

# puts subscriptions_for_products


