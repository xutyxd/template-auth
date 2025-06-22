#!/bin/bash
gunzip -c $1 | docker-compose exec -T postgres psql -U keycloak