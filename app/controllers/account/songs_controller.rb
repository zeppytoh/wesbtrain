class Account::SongsController < Account::ApplicationController
  include SortableActions
  account_load_and_authorize_resource :song, through: :team, through_association: :songs

  # GET /account/teams/:team_id/songs
  # GET /account/teams/:team_id/songs.json
  def index
    delegate_json_to_api
  end

  # GET /account/songs/:id
  # GET /account/songs/:id.json
  def show
    delegate_json_to_api
  end

  # GET /account/teams/:team_id/songs/new
  def new
  end

  # GET /account/songs/:id/edit
  def edit
  end

  # POST /account/teams/:team_id/songs
  # POST /account/teams/:team_id/songs.json
  def create
    respond_to do |format|
      if @song.save
        format.html { redirect_to [:account, @song], notice: I18n.t("songs.notifications.created") }
        format.json { render :show, status: :created, location: [:account, @song] }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @song.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /account/songs/:id
  # PATCH/PUT /account/songs/:id.json
  def update
    respond_to do |format|
      if @song.update(song_params)
        format.html { redirect_to [:account, @song], notice: I18n.t("songs.notifications.updated") }
        format.json { render :show, status: :ok, location: [:account, @song] }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @song.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /account/songs/:id
  # DELETE /account/songs/:id.json
  def destroy
    @song.destroy
    respond_to do |format|
      format.html { redirect_to [:account, @team, :songs], notice: I18n.t("songs.notifications.destroyed") }
      format.json { head :no_content }
    end
  end

  private

  if defined?(Api::V1::ApplicationController)
    include strong_parameters_from_api
  end

  def process_params(strong_params)
    # 🚅 super scaffolding will insert processing for new fields above this line.
  end
end
