# frozen_string_literal: true

require 'stripe'
require 'highline/import'

desc 'Import data from Procourse Memberships'
task 'index:test' => :environment do
  setup_api
  run_index
end


def run_index
  puts 'Run Subscriptions Index'

  current_user = User.find(25)

  index_customer = DiscourseSubscriptions::Customer.where(user_id: current_user.id)
  customer_ids = index_customer.map { |c| c.id } if index_customer
  puts 'customer_ids: '
  puts customer_ids
  subscription_ids = DiscourseSubscriptions::Subscription.where("customer_id in (?)", customer_ids).pluck(:external_id) if customer_ids
  puts 'subscription_ids: '
  puts subscription_ids
  subscriptions = []

  if subscription_ids

    plans = Stripe::Price.list(
      expand: ['data.product'],
      limit: 100
    )
    puts 'plans'
    puts plans

    customers = Stripe::Customer.list(
      email: current_user.email,
      expand: ['data.subscriptions']
    )
    puts 'customers'
    puts customers

    subscriptions = customers[:data].map do |sub_customer|
      sub_customer[:subscriptions][:data]
    end.flatten(1)
    puts 'customers[:data].map'
    puts subscriptions

    subscriptions = subscriptions.select { |sub| subscription_ids.include?(sub[:id]) }
    puts 'subscriptions.select'
    puts subscriptions

    subscriptions.map! do |subscription|
      plan = plans[:data].find { |p| p[:id] == subscription[:items][:data][0][:price][:id] }
      puts 'subscriptions.map subscription'
      puts subscription
      subscription.to_h.except!(:plan)
      puts 'except'
      puts subscription
      subscription.to_h.merge(plan: plan, product: plan[:product].to_h.slice(:id, :name))
    end

  end

  puts subscriptions
  
end

private

def setup_api
  api_key = SiteSetting.discourse_subscriptions_secret_key || ask('Input Stripe secret key')
  Stripe.api_key = api_key
end
