class Public::SongsController < Public::ApplicationController
  def index
    @q = Song.ransack(params[:q])
    @songs = params["q"] ? @q.result : nil
  end

  def show
  end
end
