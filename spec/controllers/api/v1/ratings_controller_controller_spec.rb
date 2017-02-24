require 'rails_helper'

RSpec.describe Api::V1::RatingsController, type: :controller do
  describe "create" do
    let(:user) { User.create(first_name: Faker::Name.first_name,
                             last_name: Faker::Name.last_name,
                             email: Faker::Internet.email,
                             password: Faker::Internet.password,
                             approved: true)
    }

    context "with valid data" do
      let(:beer_name) { Faker::Name.name }
      let(:beer) { user.beers.create(name: beer_name, beer_type: "ipa") }

      it "creates a rating object and updates the average_rating of a beer" do
        params = { rating: 3, beer_id: beer.id,
                   token: user.password_digest }

        expect { post :create, params: params, format: :json }
          .to change { Rating.count }.by(1)
        expect(response.status).to eq 201
        expect(JSON.parse(response.body)["average_rating"]).to eq "3.0"
      end

      context "when the beer already has a rating" do
        before do
          other_user = User.create(first_name: Faker::Name.first_name,
                             last_name: Faker::Name.last_name,
                             email: Faker::Internet.email,
                             password: Faker::Internet.password,
                             approved: true)

          beer.ratings.create(user_id: other_user.id, value: 2)
        end

        it "averages the new rating with the present rating to the nearest tenth" do
          params = { rating: 3, beer_id: beer.id,
                     token: user.password_digest }

          expect { post :create, params: params, format: :json }
            .to change { Rating.count }.by(1)

          expect(response.status).to eq 201
          expect(JSON.parse(response.body)["average_rating"]).to eq "2.5"
        end
      end

      context "when the user has already rated the beer" do
        before do
          beer.ratings.create(user_id: user.id, value: 5)
        end

        it "updates the user's rating and does not create a new rating" do
          params = { rating: 4, beer_id: beer.id,
                     token: user.password_digest }

          expect { post :create, params: params, format: :json }
            .not_to change { Rating.count }

          expect(response.status).to eq 201
          expect(JSON.parse(response.body)["average_rating"]).to eq "4.0"
        end
      end

      context "when the user rates a new beer" do
        it "adds the beer to the user's profile if the beer does not already belong to the user" do
          name = Faker::Name.name
          global_beer = Beer.create(name: name, beer_type: "ipa")

          params = { rating: 4, beer_id: global_beer.id,
                     token: user.password_digest }

          expect { post :create, params: params, format: :json }
            .to change { Rating.count &&
                         global_beer.users.count &&
                         user.beers.count }.by(1)

          expect(response.status).to eq 201
          expect(user.beers.last).to eq global_beer
        end
      end
    end

    context "when the the user is not logged in" do
      it "tells the user to login or create an account" do
        name = Faker::Name.name
        global_beer = Beer.create(name: name, beer_type: "ipa")

        params = { rating: 4, beer_id: global_beer.id, token: "" }

        expect { post :create, params: params, format: :json }
          .to raise_exception ActiveRecord::RecordNotFound
      end
    end
  end
end
