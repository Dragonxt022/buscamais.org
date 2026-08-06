class Album < ApplicationRecord
  self.table_name = "albums"

  belongs_to :user
  belongs_to :capa, class_name: "MediaFile", foreign_key: :capa_media_file_id, optional: true

  has_many :media_files, dependent: :nullify

  validates :nome, presence: true

  scope :ordenados, -> { order(:nome) }
end
