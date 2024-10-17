REPLICAS:=2
# Make sure to escape commas in the SOURCES variable like so: writeKey1\,writeKey2
SOURCES:=2lNXnjJU9xrbUERT3Uy3Po8jKbr\,2nYfF7hsD7KXz0Vp4SW1TivZCRu

ifneq (,$(or $(findstring deploy-,$(MAKECMDGOALS)),$(findstring update-,$(MAKECMDGOALS))))
    ifeq ($(DOCKER_USER),)
        $(error DOCKER_USER is not set)
    endif
    ifeq ($(K8S_NAMESPACE),)
        $(error K8S_NAMESPACE is not set)
    endif
endif

ifneq (,$(filter delete logs,$(MAKECMDGOALS)))
    ifeq ($(K8S_NAMESPACE),)
        $(error K8S_NAMESPACE is not set)
    endif
endif

ifeq ($(MAKECMDGOALS),build)
    ifeq ($(DOCKER_USER),)
        $(error DOCKER_USER is not set)
    endif
endif

.PHONY: build
build:
	docker build --progress plain -t $(DOCKER_USER)/rudder-load .
	docker push $(DOCKER_USER)/rudder-load:latest

.PHONY: deploy-%
deploy-%: build
	# Dynamically determine the service name (e.g., "http", "pulsar"...) from the target name
	@$(eval SERVICE_NAME=$*)
	@$(eval VALUES_FILE=$(PWD)/artifacts/helm/${SERVICE_NAME}_values.yaml)
	@echo Deploying using $(VALUES_FILE)
	helm install rudder-load $(PWD)/artifacts/helm \
		--namespace $(K8S_NAMESPACE) \
		--set namespace=$(K8S_NAMESPACE) \
		--set dockerUser=$(DOCKER_USER) \
		--set deployment.replicas=$(REPLICAS) \
		--set deployment.env.SOURCES="$(SOURCES)" \
		--set deployment.env.HTTP_ENDPOINT="http://$(K8S_NAMESPACE)-ingestion.$(K8S_NAMESPACE):8080/v1/batch" \
		--values $(VALUES_FILE)

.PHONY: update-%
update-%: build
	# Dynamically determine the service name (e.g., "http", "pulsar"...) from the target name
	@$(eval SERVICE_NAME=$*)
	@$(eval VALUES_FILE=$(PWD)/artifacts/helm/${SERVICE_NAME}_values.yaml)
	@echo Deploying using $(VALUES_FILE)
	helm upgrade rudder-load $(PWD)/artifacts/helm \
		--namespace $(K8S_NAMESPACE) \
		--set namespace=$(K8S_NAMESPACE) \
		--set dockerUser=$(DOCKER_USER) \
		--set deployment.replicas=$(REPLICAS) \
		--set deployment.env.SOURCES="$(SOURCES)" \
		--set deployment.env.HTTP_ENDPOINT="http://$(K8S_NAMESPACE)-ingestion.$(K8S_NAMESPACE):8080/v1/batch" \
		--values $(VALUES_FILE)

.PHONY: delete
delete:
	helm uninstall rudder-load --namespace $(K8S_NAMESPACE)

.PHONY: logs
logs:
	kubectl logs -f -n $(K8S_NAMESPACE) -l run=rudder-load
