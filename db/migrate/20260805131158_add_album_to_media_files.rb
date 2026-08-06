class AddAlbumToMediaFiles < ActiveRecord::Migration[8.1]
  def change
    add_reference :media_files, :album, null: true, foreign_key: true
  end
end
