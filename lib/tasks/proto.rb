# frozen_string_literal: true

require 'stripe'
require 'highline/import'

# puts 'Begin proto'

# desc 'Import data from Procourse Memberships'
# task 'subscriptions:pro_con' => :environment do
  # setup_api
# end

def get_stripe_prod
  puts 'Getting products from Stripe API'
  Stripe::Product.list
end

def setup_api
  api_key = ENV["STRIPE_KEY"]
  Stripe.api_key = api_key
end

setup_api
# get_stripe_prod
customers = Stripe::Customer.list
# puts "customers first 5"
# puts customers.to_a[0..1]
# puts customers

# puts "customers :data first 5"
# puts customers[:data].to_a[0..0]

cust_ret = Stripe::Customer.retrieve('cus_J3PTQx9xS8HWnd')
# p "customer"
# p cust_ret[:description].to_i
# p cust_ret[:metadata]

cust_data = customers[:data]
# p "customer id"
# puts cust_data[0][:description]

cust_data.each do |customer|
  # p customer[:description].to_i
end

# puts 'customer match'
# user_id = customers[:data].find('cus_J3PTQx9xS8HWnd')
# user_id = customers[:data].find('cus_J3PTQx9xS8HWnd')[:description]
# puts user_id

subscriptions = Stripe::Subscription.list({status: 'active'})
stripe_subs = subscriptions[:data]
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

def get_all_subscriptions(starting_after:nil )
  
  all_subscriptions = []

  loop do
    subscriptions = Stripe::Subscription.list({starting_after: starting_after, status: 'active'})

    all_subscriptions += subscriptions[:data]

    break if subscriptions[:has_more] == false

    starting_after = subscriptions[:data].last["id"]
    # p subscriptions[:data].last["id"]

  end

  all_subscriptions
end

all_subscriptions = get_all_subscriptions

# p 'all_subscriptions'
# all_subscriptions.each do |sub|
#   p sub[:id].to_s
# end

puts 'Total Active Subscriptions to Import: ' + all_subscriptions.length.to_s
