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

ActiveRecord::Schema[8.0].define(version: 2025_02_26_210308) do
  create_table "chats", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "matches", force: :cascade do |t|
    t.integer "tournament_year_id", null: false
    t.string "tournament_slug", null: false
    t.string "tournament_reference", null: false
    t.string "round"
    t.integer "duration"
    t.integer "year_of_tournament"
    t.integer "player_1_id", null: false
    t.integer "player_2_id", null: false
    t.integer "player_winner_id"
    t.string "player_1_slug", null: false
    t.string "player_2_slug", null: false
    t.string "player_winner_slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "score"
    t.string "ending"
    t.index ["player_1_id"], name: "index_matches_on_player_1_id"
    t.index ["player_2_id"], name: "index_matches_on_player_2_id"
    t.index ["player_winner_id"], name: "index_matches_on_player_winner_id"
    t.index ["tournament_year_id", "player_1_id", "player_2_id"], name: "index_matches_on_year_and_players", unique: true
    t.index ["tournament_year_id"], name: "index_matches_on_tournament_year_id"
  end

  create_table "messages", force: :cascade do |t|
    t.integer "chat_id", null: false
    t.text "content"
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chat_id"], name: "index_messages_on_chat_id"
  end

  create_table "player_rankings", force: :cascade do |t|
    t.integer "tennis_player_id", null: false
    t.date "week_date", null: false
    t.integer "ranking", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tennis_player_id"], name: "index_player_rankings_on_tennis_player_id"
  end

  create_table "tennis_players", force: :cascade do |t|
    t.string "full_name"
    t.date "date_of_birth"
    t.integer "height_in_cm"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "tennis_player_slug", null: false
    t.string "player_url"
    t.integer "career_highest_ranking_singles"
    t.date "career_highest_ranking_date_singles"
    t.decimal "career_prize_money", precision: 15, scale: 2
    t.string "play_hand"
    t.integer "age"
    t.integer "weight_in_kg"
    t.string "place_of_birth"
    t.string "current_coach"
    t.integer "nb_career_titles_singles"
    t.integer "nb_career_wins_singles"
    t.integer "nb_career_losses_singles"
    t.integer "nb_career_matches_singles"
    t.integer "nb_career_wins_doubles"
    t.integer "nb_career_losses_doubles"
    t.integer "nb_career_matches_doubles"
    t.integer "nb_career_titles_doubles"
    t.integer "career_highest_ranking_doubles"
    t.date "career_highest_ranking_date_doubles"
    t.string "back_hand"
    t.boolean "active_player", default: true
    t.boolean "double_specialist", default: false
    t.string "nationality"
    t.index ["tennis_player_slug"], name: "index_tennis_players_on_tennis_player_slug", unique: true
  end

  create_table "tournament_years", force: :cascade do |t|
    t.string "tournament_reference"
    t.string "tournament_slug"
    t.string "tournament_name"
    t.string "tournament_category"
    t.string "tournament_type"
    t.string "tournament_winner_single_tennis_player_slug"
    t.integer "tournament_year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "messages", "chats"
  add_foreign_key "player_rankings", "tennis_players"
end
