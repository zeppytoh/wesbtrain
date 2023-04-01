# Api::V1::ApplicationController is in the starter repository and isn't
# needed for this package's unit tests, but our CI tests will try to load this
# class because eager loading is set to `true` when CI=true.
# We wrap this class in an `if` statement to circumvent this issue.
if defined?(Api::V1::ApplicationController)
  class Api::V1::SongsController < Api::V1::ApplicationController
    account_load_and_authorize_resource :song, through: :team, through_association: :songs

    # GET /api/v1/teams/:team_id/songs
    def index
    end

    # GET /api/v1/songs/:id
    def show
    end

    # POST /api/v1/teams/:team_id/songs
    def create
      if @song.save
        render :show, status: :created, location: [:api, :v1, @song]
      else
        render json: @song.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /api/v1/songs/:id
    def update
      if @song.update(song_params)
        render :show
      else
        render json: @song.errors, status: :unprocessable_entity
      end
    end

    # DELETE /api/v1/songs/:id
    def destroy
      @song.destroy
    end

    private

    module StrongParameters
      # Only allow a list of trusted parameters through.
      def song_params
        strong_params = params.require(:song).permit(
          *permitted_fields,
          :title,
          :key,
          :author,
          :body,
          :video_url,
          # 🚅 super scaffolding will insert new fields above this line.
          *permitted_arrays,
          # 🚅 super scaffolding will insert new arrays above this line.
        )

        process_params(strong_params)

        strong_params
      end
    end

    include StrongParameters
  end
else
  class Api::V1::SongsController
  end
end
