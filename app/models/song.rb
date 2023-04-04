class Song < ApplicationRecord
  include Sortable
  # 🚅 add concerns above.

  # 🚅 add attribute accessors above.

  belongs_to :team
  # 🚅 add belongs_to associations above.

  # 🚅 add has_many associations above.

  # 🚅 add has_one associations above.

  # 🚅 add scopes above.

  validates :title, presence: true
  validates :body, presence: true, length: {minimum: 20, maximum: 1500}
  # 🚅 add validations above.

  # 🚅 add callbacks above.

  # 🚅 add delegations above.

  def collection
    team.songs
  end

  # データベースではkeyはc_sharpとかになっているのでC♯などを表示したい時はこれを使う。
  def original_key
    all_keys.dig(key.to_sym)
  end

  def all_keys
    I18n.t(".songs.fields.key.options")
  end
  # 🚅 add methods above.
end
