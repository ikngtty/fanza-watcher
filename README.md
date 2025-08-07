# Fanza Watcher

## Preparation
Set env var `WEBHOOK_URL`.
Set a service account key of firestore to `config/service-account-file.json`.

## Run

```shell
$ make build
$ make run ARGS="add <cid>" # Besides `add`.
```

```
Commands:
  main.rb add cid         # add a video to watch
  main.rb help [COMMAND]  # Describe available commands or one specific command
  main.rb remove cid      # remove a video
  main.rb update          # update videos
  main.rb view            # view added videos
```
