# frozen_string_literal: true

require 'stripe'
require 'highline/import'

puts 'Begin proto'

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

puts "customer"
cust_ret = Stripe::Customer.retrieve('cus_J3PTQx9xS8HWnd')
p cust_ret[:description].to_i
# p cust_ret[:metadata]

puts "customer id"
cust_data = customers[:data]
# puts cust_data[0][:description]

cust_data.each do |customer|
  # p customer[:description].to_i
end

all_subscriptions = []

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
  subscriptions = Stripe::Subscription.list
  all_subscriptions = subscriptions[:data]

  loop do
    break if subscriptions[:has_more] == false 
    all_subscriptions << Stripe::Subscription.list({starting_after: starting_after})

  end

  if starting_after
    all_subscriptions << Stripe::Subscription.list({starting_after: starting_after})
  end

end