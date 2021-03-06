require 'spec_helper'

describe "Aggregating a movie" do
  let(:aggregator) { WorthWatching::Aggregator.new("rt_api_key", "tmdb_api_key") }

  describe 'retrieving individual movie info' do
    before do
      # Single movie RottenTomatoes
      json_response = File.read(File.dirname(__FILE__) + "/../support/json_responses/toy_story_rt.json")
      stub_request(:get, /api\.rottentomatoes\.com\/api\/public\/v1\.0\/movies\/770672122\.json\?apikey\=.*/).to_return(:status => 200, :body => json_response,:headers => {"content-type"=>["application/json; charset=utf-8"]})

      # Single movie OMDB
      json_response = File.read(File.dirname(__FILE__) + "/../support/json_responses/toy_story_omdb.json")
      stub_request(:get, "http://www.omdbapi.com/?i=tt0435761").to_return(:status => 200, :body => json_response,:headers => {"content-type"=>["application/json; charset=utf-8"]})

      # Single movie TMDB
      json_response = File.read(File.dirname(__FILE__) + "/../support/json_responses/toy_story_tmdb.json")
      stub_request(:get, /api\.themoviedb\.org\/3\/movie\/tt0435761\?api_key\=.*/).to_return(:status => 200, :body => json_response,:headers => {"content-type"=>["application/json; charset=utf-8"]})

      # RottenTomatoes reviews
      json_response = File.read(File.dirname(__FILE__) + "/../support/json_responses/toy_story_reviews_rt.json")
      stub_request(:get, /api\.rottentomatoes\.com\/api\/public\/v1\.0\/movies\/770672122\/reviews\.json\?apikey\=.*&country=uk&page=1&page_limit=5&review_type=top_critic/).to_return(:status => 200, :body => json_response,:headers => {"content-type"=>["application/json; charset=utf-8"]})

      # Single movie MetaCritic
      json_response = File.read(File.dirname(__FILE__) + "/../support/html_responses/toy_story_mc.html")
      stub_request(:get, "http://www.metacritic.com/search/movie/Toy+Story+3/results").to_return(:status => 200, :body => json_response,:headers => {"content-type"=>["text/html; charset=utf-8"]})
    end

    let(:movie) do
      aggregator.aggregate_movie("770672122")
    end

    it "should have Rotten Tomato rating 99" do
      expect(movie.rt_rating).to eq(99)
    end

    it "should have a link to RT page 'http://www.rottentomatoes.com/m/toy_story_3/" do
      expect(movie.rt_url).to eq("http://www.rottentomatoes.com/m/toy_story_3/")
    end

    it "should have IMDB rating of 8.5" do
      expect(movie.imdb_rating).to eq(8.5)
    end

    it "should have IMDB url 'http://www.imdb.com/title/tt0435761/'" do
      expect(movie.imdb_url).to eq("http://www.imdb.com/title/tt0435761/")
    end

    it "should have metacritic rating of 92" do
      expect(movie.metacritic_rating).to eq(92)
    end

    it "should have metacritic url 'http://www.metacritic.com/movie/toy-story-3'" do
      expect(movie.metacritic_url).to eq("http://www.metacritic.com/movie/toy-story-3")
    end

    it "should have the correct poster url" do
      expect(movie.poster).to eq("http://cf2.imgobject.com/t/p/original/tOwAAVeL1p3ls9dhOBo45ElodU3.jpg")
    end

    it "should have a ratings summary" do
      summary = "Rotten Tomatoes rating: 99\nIMDB rating: 8.5\nMetacritic rating: 92\n"
      expect(movie.rating_summary).to eq(summary)
    end

    describe "retrieving movie reviews" do
      let (:reviews) { movie.reviews }

      it "should have an author" do
        expect(reviews.first).to be_an_instance_of(WorthWatching::WrittenReview)
      end

      it "should have a date" do
        expect(reviews.first.date).to eq(Date.new(2013,8,4))
      end

      it "should have rating" do
        expect(reviews.first.rating).to eq("fresh")
      end

      it "should have a source" do
        expect(reviews.first.source).to eq("Village Voice")
      end

      it "should have a review quote" do
        expect(reviews.first.quote).to eq("When teenaged Andy plops down on the grass to share his old toys with a shy little girl, the film spikes with sadness and layered pleasure -- a concise, deeply wise expression of the ephemeral that feels real and yet utterly transporting.")
      end

      it "should have a link to the review" do
        expect(reviews.first.link).to eq("http://www.villagevoice.com/2010-06-15/film/toys-are-us-in-toy-story-3/full/")
      end
    end

    context "when the OMDB API has no IMDb rating info for a movie" do
      before do
        json_response = File.read(File.dirname(__FILE__) + "/../support/json_responses/captain_america_rt.json")
        stub_request(:get, /api\.rottentomatoes\.com\/api\/public\/v1\.0\/movies\/771312513\.json\?apikey\=.*/).to_return(:status => 200, :body => json_response,:headers => {"content-type"=>["application/json; charset=utf-8"]})

        json_response = File.read(File.dirname(__FILE__) + "/../support/json_responses/captain_america_omdb.json")
        stub_request(:get, "http://www.omdbapi.com/?i=tt1843866").to_return(:status => 200, :body => json_response,:headers => {"content-type"=>["application/json; charset=utf-8"]})

        json_response = File.read(File.dirname(__FILE__) + "/../support/json_responses/captain_america_tmdb.json")
        stub_request(:get, /api\.themoviedb\.org\/3\/movie\/tt1843866\?api_key\=.*/).to_return(:status => 200, :body => json_response,:headers => {"content-type"=>["application/json; charset=utf-8"]})

        json_response = File.read(File.dirname(__FILE__) + "/../support/json_responses/captain_america_reviews_rt.json")
        stub_request(:get, /api\.rottentomatoes\.com\/api\/public\/v1\.0\/movies\/771312513\/reviews\.json\?apikey\=.*&country=uk&page=1&page_limit=5&review_type=top_critic/).to_return(:status => 200, :body => json_response,:headers => {"content-type"=>["application/json; charset=utf-8"]})

        json_response = File.read(File.dirname(__FILE__) + "/../support/html_responses/captain_america_mc.html")
        stub_request(:get, "http://www.metacritic.com/search/movie/Captain+America:+The+Winter+Soldier/results").to_return(:status => 200, :body => json_response,:headers => {"content-type"=>["text/html; charset=utf-8"]})

        json_response = File.read(File.dirname(__FILE__) + "/../support/html_responses/captain_america_imdb.html")
        stub_request(:get, "http://m.imdb.com/title/tt1843866/").to_return(:status => 200, :body => json_response,:headers => {"content-type"=>["text/html; charset=utf-8"]})
      end

      it "scrapes the rating directly from the movie's IMDb page" do
        movie = aggregator.aggregate_movie("771312513")
        expect(movie.imdb_rating).to eq(8.3)
      end
    end
  end

  context "when the Rotten Tomatoes API does not return the IMDb ID of the movie" do
    before do
      # Single movie RottenTomatoes, with insufficient data
      json_response = File.read(File.dirname(__FILE__) + "/../support/json_responses/a_movie_with_little_info_rt.json")
      stub_request(:get, /api\.rottentomatoes\.com\/api\/public\/v1\.0\/movies\/11111111\.json\?apikey\=.*/).to_return(:status => 200, :body => json_response,:headers => {"content-type"=>["application/json; charset=utf-8"]})
    end

    it "raises an exception" do
      expect { aggregator.aggregate_movie("11111111") }.to raise_exception(InsufficientDataError,
                                                                           "No IMDb ID present, can't aggregate")
    end
  end
end
