# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)



#script for update missing email for billing_addresses
billing_addresses = BillingAddress.all
billing_addresses.each do |bill|
  user = bill.user
  if user
    bill.email = user.email
    bill.save(validate:false)
  end
end
