# Stack-agnostic Dockerfile template. Adapt to the project's stack.
# See the `dockerize` skill for the decision guide (when NOT to containerize).
#
# Guidelines:
#  - Pick a small official base image (prefer -slim / -alpine variants).
#  - Use a multi-stage build for compiled stacks (build stage -> tiny runtime stage).
#  - Copy dependency manifests first to maximize layer caching, then the source.
#  - Run as a non-root user.
#  - Pass configuration via environment variables; never bake secrets into the image.

# ----- Build stage (drop if your stack is interpreted and needs no build) -----
# FROM <base>:<tag> AS build
# WORKDIR /app
# COPY <dependency-manifests> ./
# RUN <install dependencies>
# COPY . .
# RUN <build command>

# ----- Runtime stage -----
FROM <base>:<tag>

# Create and use a non-root user
RUN addgroup --system app && adduser --system --ingroup app app
USER app

WORKDIR /app

# Install runtime dependencies (copy from build stage if multi-stage)
# COPY --from=build /app/<deps> ./<deps>
# COPY --from=build /app/<artifact> ./

# Copy source (interpreted stacks) or built artifacts (compiled stacks)
COPY --chown=app:app . .

# Document the port the service listens on
# EXPOSE 8080

# Start command — replace with the real entrypoint
CMD ["<run-command>"]
