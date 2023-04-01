require "controllers/api/v1/test"

class Api::V1::SongsControllerTest < Api::Test
  def setup
    # See `test/controllers/api/test.rb` for common set up for API tests.
    super

    @song = build(:song, team: @team)
    @other_songs = create_list(:song, 3)

    @another_song = create(:song, team: @team)

    # 🚅 super scaffolding will insert file-related logic above this line.
    @song.save
    @another_song.save
  end

  # This assertion is written in such a way that new attributes won't cause the tests to start failing, but removing
  # data we were previously providing to users _will_ break the test suite.
  def assert_proper_object_serialization(song_data)
    # Fetch the song in question and prepare to compare it's attributes.
    song = Song.find(song_data["id"])

    assert_equal_or_nil song_data['title'], song.title
    assert_equal_or_nil song_data['key'], song.key
    assert_equal_or_nil song_data['author'], song.author
    assert_equal_or_nil song_data['body'], song.body
    assert_equal_or_nil song_data['video_url'], song.video_url
    # 🚅 super scaffolding will insert new fields above this line.

    assert_equal song_data["team_id"], song.team_id
  end

  test "index" do
    # Fetch and ensure nothing is seriously broken.
    get "/api/v1/teams/#{@team.id}/songs", params: {access_token: access_token}
    assert_response :success

    # Make sure it's returning our resources.
    song_ids_returned = response.parsed_body.map { |song| song["id"] }
    assert_includes(song_ids_returned, @song.id)

    # But not returning other people's resources.
    assert_not_includes(song_ids_returned, @other_songs[0].id)

    # And that the object structure is correct.
    assert_proper_object_serialization response.parsed_body.first
  end

  test "show" do
    # Fetch and ensure nothing is seriously broken.
    get "/api/v1/songs/#{@song.id}", params: {access_token: access_token}
    assert_response :success

    # Ensure all the required data is returned properly.
    assert_proper_object_serialization response.parsed_body

    # Also ensure we can't do that same action as another user.
    get "/api/v1/songs/#{@song.id}", params: {access_token: another_access_token}
    assert_response :not_found
  end

  test "create" do
    # Use the serializer to generate a payload, but strip some attributes out.
    params = {access_token: access_token}
    song_data = JSON.parse(build(:song, team: nil).to_api_json.to_json)
    song_data.except!("id", "team_id", "created_at", "updated_at")
    params[:song] = song_data

    post "/api/v1/teams/#{@team.id}/songs", params: params
    assert_response :success

    # # Ensure all the required data is returned properly.
    assert_proper_object_serialization response.parsed_body

    # Also ensure we can't do that same action as another user.
    post "/api/v1/teams/#{@team.id}/songs",
      params: params.merge({access_token: another_access_token})
    assert_response :not_found
  end

  test "update" do
    # Post an attribute update ensure nothing is seriously broken.
    put "/api/v1/songs/#{@song.id}", params: {
      access_token: access_token,
      song: {
        title: 'Alternative String Value',
        author: 'Alternative String Value',
        body: 'Alternative String Value',
        video_url: 'Alternative String Value',
        # 🚅 super scaffolding will also insert new fields above this line.
      }
    }

    assert_response :success

    # Ensure all the required data is returned properly.
    assert_proper_object_serialization response.parsed_body

    # But we have to manually assert the value was properly updated.
    @song.reload
    assert_equal @song.title, 'Alternative String Value'
    assert_equal @song.author, 'Alternative String Value'
    assert_equal @song.body, 'Alternative String Value'
    assert_equal @song.video_url, 'Alternative String Value'
    # 🚅 super scaffolding will additionally insert new fields above this line.

    # Also ensure we can't do that same action as another user.
    put "/api/v1/songs/#{@song.id}", params: {access_token: another_access_token}
    assert_response :not_found
  end

  test "destroy" do
    # Delete and ensure it actually went away.
    assert_difference("Song.count", -1) do
      delete "/api/v1/songs/#{@song.id}", params: {access_token: access_token}
      assert_response :success
    end

    # Also ensure we can't do that same action as another user.
    delete "/api/v1/songs/#{@another_song.id}", params: {access_token: another_access_token}
    assert_response :not_found
  end
end
