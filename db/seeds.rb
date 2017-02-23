# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
types = []
20.times do
  types << Faker::Name.name.downcase
end

5.times do
  User.create(first_name: Faker::Name.first_name,
              last_name: Faker::Name.last_name,
              email: Faker::Internet.email,
              password: Faker::Internet.password)
end

5000.times do
  beer = Beer.create(name: Faker::Name.name.downcase,
                     beer_type: types.sample,
                     approved: true)

  rating = Rating.find_or_initialize_by(user_id: User.all.sample.id,
                                        beer_id: Beer.all.sample.id)
  rating.value = rand(1..5)
  rating.save

  puts beer.name
end
