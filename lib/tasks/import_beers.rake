require "csv"

desc "import beers"
task import_beers: :environment do
  CSV.foreach((Rails.root + "lib/tasks/csvs/beer_data.csv").join, headers: true) do |row|
    Beer.create(name: row["Beer"].downcase,
                beer_type: row["Style"].downcase,
                brand: row["Brewery"].downcase,
                abv: row["ABV"].sub("%", ""),
                average_rating: row["rAvg"],
                approved: true)
                puts row["Beer"].downcase
  end
end
