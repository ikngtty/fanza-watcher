# Fanza Watcher

## Preparation
Make `.env` file with reffering `.env.sample`.
Set a service account key of firestore to `config/service-account-file.json`.

## Run

```shell
$ make build
$ make run ARGS="add <cid>" # Besides `add`.
```

```
Commands:
  main.rb add CID         # Add a video to watch
  main.rb help [COMMAND]  # Describe available commands or one specific command
  main.rb remove CID      # Remove a video
  main.rb scrape CID      # Scrape a video (for debug)
  main.rb update          # Update videos
  main.rb view            # View added videos
```
