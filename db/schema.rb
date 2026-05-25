# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_05_25_180554) do
  create_table "action_text_rich_texts", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.text "body", size: :long
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "article_tags", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "article_id", null: false
    t.datetime "created_at", null: false
    t.bigint "tag_id", null: false
    t.datetime "updated_at", null: false
    t.index ["article_id"], name: "index_article_tags_on_article_id"
    t.index ["tag_id"], name: "index_article_tags_on_tag_id"
  end

  create_table "articles", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.datetime "agendado_em"
    t.bigint "author_id"
    t.bigint "category_id"
    t.text "conteudo"
    t.datetime "created_at", null: false
    t.boolean "destaque", default: false, null: false
    t.string "imagem_capa"
    t.datetime "publicado_em"
    t.text "resumo"
    t.string "slug", null: false
    t.integer "status", default: 0, null: false
    t.integer "tempo_leitura", default: 0
    t.string "titulo", null: false
    t.datetime "updated_at", null: false
    t.integer "visualizacoes", default: 0, null: false
    t.index ["author_id"], name: "index_articles_on_author_id"
    t.index ["category_id"], name: "index_articles_on_category_id"
    t.index ["destaque"], name: "index_articles_on_destaque"
    t.index ["publicado_em"], name: "index_articles_on_publicado_em"
    t.index ["slug"], name: "index_articles_on_slug", unique: true
    t.index ["status"], name: "index_articles_on_status"
  end

  create_table "categories", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.boolean "ativo", default: true, null: false
    t.string "cor", default: "#1a56db"
    t.datetime "created_at", null: false
    t.text "descricao"
    t.string "nome", null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["nome"], name: "index_categories_on_nome", unique: true
    t.index ["slug"], name: "index_categories_on_slug", unique: true
  end

  create_table "comment_likes", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "comment_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["comment_id"], name: "index_comment_likes_on_comment_id"
    t.index ["user_id", "comment_id"], name: "index_comment_likes_on_user_id_and_comment_id", unique: true
    t.index ["user_id"], name: "index_comment_likes_on_user_id"
  end

  create_table "comments", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "aprovado_por"
    t.bigint "article_id", null: false
    t.text "conteudo", null: false
    t.datetime "created_at", null: false
    t.integer "likes_count", default: 0, null: false
    t.integer "parent_id"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["article_id"], name: "index_comments_on_article_id"
    t.index ["parent_id"], name: "index_comments_on_parent_id"
    t.index ["status"], name: "index_comments_on_status"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "friendly_id_slugs", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.datetime "created_at"
    t.string "scope"
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, length: { slug: 70, scope: 70 }
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", length: { slug: 140 }
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
  end

  create_table "media_files", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "altura"
    t.datetime "created_at", null: false
    t.text "descricao"
    t.integer "largura"
    t.string "nome"
    t.integer "tamanho"
    t.string "tipo"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_media_files_on_user_id"
  end

  create_table "notifications", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "dados"
    t.boolean "lida", default: false, null: false
    t.bigint "notificable_id"
    t.string "notificable_type"
    t.string "tipo", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["notificable_type", "notificable_id"], name: "index_notifications_on_notificable_type_and_notificable_id"
    t.index ["user_id", "lida"], name: "index_notifications_on_user_id_and_lida"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "reading_histories", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "article_id", null: false
    t.datetime "created_at", null: false
    t.datetime "lido_em", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["article_id"], name: "index_reading_histories_on_article_id"
    t.index ["lido_em"], name: "index_reading_histories_on_lido_em"
    t.index ["user_id", "article_id"], name: "index_reading_histories_on_user_id_and_article_id", unique: true
    t.index ["user_id"], name: "index_reading_histories_on_user_id"
  end

  create_table "saved_articles", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "article_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["article_id"], name: "index_saved_articles_on_article_id"
    t.index ["user_id", "article_id"], name: "index_saved_articles_on_user_id_and_article_id", unique: true
    t.index ["user_id"], name: "index_saved_articles_on_user_id"
  end

  create_table "site_settings", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "chave", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "valor"
    t.index ["chave"], name: "index_site_settings_on_chave", unique: true
  end

  create_table "subscriptions", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "plano", default: 0, null: false
    t.date "prox_cobranca"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.decimal "valor", precision: 8, scale: 2
    t.index ["user_id"], name: "index_subscriptions_on_user_id", unique: true
  end

  create_table "tags", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "nome", null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["nome"], name: "index_tags_on_nome", unique: true
    t.index ["slug"], name: "index_tags_on_slug", unique: true
  end

  create_table "user_topics", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["category_id"], name: "index_user_topics_on_category_id"
    t.index ["user_id", "category_id"], name: "index_user_topics_on_user_id_and_category_id", unique: true
    t.index ["user_id"], name: "index_user_topics_on_user_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.boolean "ativo", default: true, null: false
    t.string "avatar"
    t.text "bio"
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "nome"
    t.string "provider"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role"
    t.string "uid"
    t.datetime "updated_at", null: false
    t.index ["ativo"], name: "index_users_on_ativo"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "article_tags", "articles"
  add_foreign_key "article_tags", "tags"
  add_foreign_key "articles", "categories"
  add_foreign_key "articles", "users", column: "author_id"
  add_foreign_key "comment_likes", "comments"
  add_foreign_key "comment_likes", "users"
  add_foreign_key "comments", "articles"
  add_foreign_key "comments", "users"
  add_foreign_key "media_files", "users"
  add_foreign_key "notifications", "users"
  add_foreign_key "reading_histories", "articles"
  add_foreign_key "reading_histories", "users"
  add_foreign_key "saved_articles", "articles"
  add_foreign_key "saved_articles", "users"
  add_foreign_key "subscriptions", "users"
  add_foreign_key "user_topics", "categories"
  add_foreign_key "user_topics", "users"
end
