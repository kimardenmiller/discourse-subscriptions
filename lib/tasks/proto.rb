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

puts "customer id"
puts customers[:data][0][:description]

# puts 'customer match'
user_id = customers[:data].find('cus_J3PTQx9xS8HWnd')
# user_id = customers[:data].find('cus_J3PTQx9xS8HWnd')[:description]
puts user_id

# subscriptions = Stripe::Subscription.list
# strip_cust = subscriptions[:data][0][:customer]