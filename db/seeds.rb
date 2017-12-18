# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


Duration.create([
  { duration: 1, duration_desc: "Very Small & Quick Job - Simple" },
  { duration: 2, duration_desc: "Small & Semi-quick Job - Fairly Simple" },
  { duration: 3, duration_desc: "Average size job - Average time & effort" },
  { duration: 4, duration_desc: "Large Job - More time needed" },
  { duration: 5, duration_desc: "Very Large Job - time-consuming - above average commitment" }
])

ExtraDuration.create([
  { duration: 1, duration_desc: "Very Small & Quick Job - Simple" },
  { duration: 2, duration_desc: "Small & Semi-quick Job - Fairly Simple" },
  { duration: 3, duration_desc: "Average size job - Average time & effort" },
  { duration: 4, duration_desc: "Large Job - More time needed" },
  { duration: 5, duration_desc: "Very Large Job - time-consuming - above average commitment" },
  { duration: 0, duration_desc: "No Special Job - For Extra Time Duration only" }
])

Key.create([
  { name: "Google Places API", key: "AIzaSyDVo1wSditnf5dqWnDXSCbG_DYmLK_uiEY"}
])