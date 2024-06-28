ARG AGENT_VERSION=1.27.3

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build-env
WORKDIR /App

COPY ./Program.cs ./
COPY ./WebApplication11.csproj ./
COPY ./appsettings.json ./

RUN dotnet restore
RUN dotnet publish -c Release -o out

FROM mcr.microsoft.com/dotnet/aspnet:8.0
ARG AGENT_VERSION
WORKDIR /App
COPY --from=build-env /App/out .

RUN apt-get -y update;
RUN apt-get -y install zip curl

RUN curl -L -o elastic_apm_profiler_${AGENT_VERSION}.zip \
    https://github.com/elastic/apm-agent-dotnet/releases/download/v${AGENT_VERSION}/elastic_apm_profiler_${AGENT_VERSION}-linux-x64.zip && \
    unzip elastic_apm_profiler_${AGENT_VERSION}.zip -d /elastic_apm_profiler

# Commented out the below which where useful during local testing to rule out possible causes
# and to test a local (amended) build of the profiler zip.

# COPY ./elastic /elastic_apm_profiler
# RUN rm /elastic_apm_profiler/elastic_apm_profiler.deps.json
# RUN rm /elastic_apm_profiler/elastic_apm_profiler.dll
# RUN rm /elastic_apm_profiler/elastic_apm_profiler.pdb
# RUN rm /elastic_apm_profiler/elastic_apm_profiler.xml
# RUN chmod g+w /elastic_apm_profiler/libelastic_apm_profiler.so

ENV CORECLR_ENABLE_PROFILING=1
ENV CORECLR_PROFILER={FA65FE15-F085-4681-9B20-95E04F6C03CC}
ENV CORECLR_PROFILER_PATH=/elastic_apm_profiler/libelastic_apm_profiler.so
ENV ELASTIC_APM_PROFILER_HOME=/elastic_apm_profiler
ENV ELASTIC_APM_PROFILER_INTEGRATIONS=/elastic_apm_profiler/integrations.yml
ENV ELASTIC_APM_SERVER_URL="<insert-apm-server-url-here>"
ENV ELASTIC_APM_SECRET_TOKEN="<insert-secret-token-here>"
ENV ELASTIC_APM_PROFILER_LOG=Trace
ENV ELASTIC_APM_PROFILER_LOG_DIR=/elastic_apm_profiler/logs
ENV ELASTIC_APM_PROFILER_LOG_TARGETS=stdout;file

ENTRYPOINT ["dotnet", "WebApplication11.dll"]