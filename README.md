# Azure Docker Test

This web project exists to reproduce an issue with Azure Web Apps for Containers, where stopping the web app does not properly stop the container, but kills it instead, terminating any running processes.

## Configuration

To run this app, you need to specify a connection string for Azure storage:

```bash
$ dotnet user-secrets set BlobStorageConnection "[your-connection-string]"
```

When running this app as a Docker container, you'll need to pass that same connection string as an environment variable:
```bash
$ docker run -d -p 80:80 -e BlobStorageConnection="[your-connection-string]" [image-name]
```
