# Docker APM Agent Repro

This is a small sample to use when testing the profiler-based agent not working
when used against .NET in Docker containers. It can be used to build various 
container images used to test the different combinations of Agent version and 
runtime version.

The `Dockerfile` can be updated to change the APM agent version and also the
SDK/runtime version.

Build an image from the root of the directory:

```
docker build -t profiler/8.0_1.27.3 . --no-cache
```

Run that image:
```
docker run -p 51000:8080 profiler/8.0_1.27.3
```

If the profiler is loaded it should also configure the agent and spit a lot 
of trace logs to stdout and the log file at the configured directory.