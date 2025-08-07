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
  main.rb add cid         # Add a video to watch
  main.rb help [COMMAND]  # Describe available commands or one specific command
  main.rb remove cid      # Remove a video
  main.rb update          # Update videos
  main.rb view            # View added videos
```
