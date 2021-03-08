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
    customers = Stripe::Subscription.list({starting_after: starting_after, status: 'active'})

    all_customers += customers[:data]

    break if customers[:has_more] == false

    starting_after = customers[:data].last["id"]

  end

  all_customers
end

setup_api

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

all_subscriptions = get_procourse_stripe_subs
puts 'Total Active Subscriptions to Import: ' + all_subscriptions.length.to_s
# p all_subscriptions[0][:items][:data][0][:price][:product]

all_products = get_procourse_stripe_products
puts 'Total Active Products to Import: ' + all_products.length.to_s

all_customers = get_procourse_stripe_customers
puts 'Total Active Customers to Import: ' + all_customers.length.to_s

product_ids = %w[prod_FuKoqUHCNs49km prod_FuKoqUHCNs49km_xyz]
puts product_ids.include?(all_subscriptions[0][:items][:data][0][:price][:product])
# product_ids = [{items: 'prod_FuKoqUHCNs49km'}]
# subscriptions_for_products = all_subscriptions[:data].select { |sub| product_ids.include?(sub) }
subscriptions_for_products = all_subscriptions.select { |sub| product_ids.include?(sub[:items][:data][0][:price][:product]) }
puts 'subscriptions_for_products to Import: ' + subscriptions_for_products.length.to_s
# puts subscriptions_for_products
