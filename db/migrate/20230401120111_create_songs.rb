class CreateSongs < ActiveRecord::Migration[7.0]
  def change
    create_table :songs do |t|
      t.references :team, null: false, foreign_key: true
      t.integer :sort_order
      t.string :title
      t.string :key
      t.string :author
      t.text :body
      t.string :video_url

      t.timestamps
    end
  end
end
