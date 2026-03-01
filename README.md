# README

To test this, make sure you have ruby 3.4.2.
1. Pull this repo, and open 2 terminals.
2. In first terminal, do, `yarn`, `bundle`, `rails db:create`, `bin/dev`
3. In 2nd terminal, cd into `customer_apis`, and below commands to install and run sample api servers.
   ```bash
   BASE=$(pwd)
   ```
   ```bash
   for i in 1 2 3 4 5; do   cd $BASE/api${i} && bundle install; done
   ```
   ```bash
   foreman start
   ```
