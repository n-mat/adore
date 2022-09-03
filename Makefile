include adore_if_ros/make_gadgets/Makefile

SHELL:=/bin/bash

.DEFAULT_GOAL := all

ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
MAKEFLAGS += --no-print-directory

CATKIN_WORKSPACE_DIRECTORY=catkin_workspace

.EXPORT_ALL_VARIABLES:
DOCKER_BUILDKIT?=1
DOCKER_CONFIG?=$(shell realpath ${ROOT_DIR})/apt_cacher_ng_docker

DOCKER_GID := $(shell getent group | grep docker | cut -d":" -f3)
USER := $(shell whoami)
UID := $(shell id -u)
GID := $(shell id -g)

.PHONY: all
all: \
     submodules_update \
     docker_group_check \
     root_check \
     start_apt_cacher_ng \
     build_adore_if_ros_msg\
     build_adore_if_ros_scheduling\
     build_adore_if_ros\
     build_adore_if_v2x \
     build_adore_v2x_sim \
     build_plotlabserver \
     build_libadore\
     build_sumo_if_ros \
     get_apt_cacher_ng_cache_statistics\
     

.PHONY: build
build: all

.PHONY: clean
clean: 
	cd plotlabserver && make clean
	cd sumo_if_ros && make clean
	cd adore_if_ros_msg && make clean
	cd libadore && make clean
	cd adore_if_ros && make clean
	cd adore_if_v2x && make clean
	cd adore_if_ros/adore_if_ros_scheduling && make clean
	cd adore_if_ros/make_gadgets/docker && make delete_all_none_tags

.PHONY: start_apt_cacher_ng 
start_apt_cacher_ng: ## Start apt cacher ng service
	cd apt_cacher_ng_docker && \
    make up

.PHONY: stop_apt_cacher_ng 
stop_apt_cacher_ng: ## Stop apt cacher ng service
	cd apt_cacher_ng_docker && make down

.PHONY: get_apt_cacher_ng_cache_statistics 
get_apt_cacher_ng_cache_statistics: ## returns the cache statistics for apt cahcer ng
	@cd apt_cacher_ng_docker && \
	make get_cache_statistics

.PHONY: submodules_update 
submodules_update: # Updates submodules
	git submodule update --init --recursive

.PHONY: build_adore_if_ros 
build_adore_if_ros: ## build adore_if_ros
	cd adore_if_ros && \
    make
.PHONY: build_adore_if_ros_msg
build_adore_if_ros_msg: 
	cd adore_if_ros_msg && \
	make
	
.PHONY: build_plotlabserver 
build_plotlabserver: ## Build plotlabserver
	cd plotlabserver && \
    make

.PHONY: build_adore_if_v2x 
build_adore_if_v2x: ## Build adore_if_v2x
	cd adore_if_v2x && \
    make

.PHONY: build_adore_v2x_sim 
build_adore_v2x_sim: ## Build adore_v2x_sim
	cd adore_v2x_sim && \
    make

.PHONY: build_libadore 
build_libadore: start_apt_cacher_ng ## Build libadore
	cd libadore && \
    make

.PHONY: build_sumo_if_ros 
build_sumo_if_ros: ## Build sumo_if_ros
	cd sumo_if_ros && \
    make
    
.PHONY: build_adore_if_ros_scheduling 
build_adore_if_ros_scheduling: ## Build adore_if_ros_scheduling
	cd adore_if_ros/adore_if_ros_scheduling && \
    make

.PHONY: test 
test:
	mkdir -p .log && \
    cd libadore && \
	make test | tee ${ROOT_DIR}/.log/libadore_unit_test.log; exit $$PIPESTATUS

.PHONY: lint_sumo_if_ros 
lint_sumo_if_ros:
	cd sumo_if_ros && make lint

.PHONY: lint 
lint: ## Run linting for all modules
	find . -name "**lint_report.log" -exec rm -rf {} \;
	EXIT_STATUS=0; \
        (cd sumo_if_ros && make lint) || EXIT_STATUS=$$? && \
        (cd libadore && make lint) || EXIT_STATUS=$$? && \
        (cd adore_if_ros && make lint) || EXIT_STATUS=$$? && \
	    find . -name "**lint_report.log" -print0 | xargs -0 -I {} mv {} .log/ && \
        exit $$EXIT_STATUS
 
.PHONY: lizard 
lizard: ## Run lizard static analysis tool for all modules
	find . -name "**lizard_report.**" -exec rm -rf {} \;
	EXIT_STATUS=0; \
        (cd sumo_if_ros && make lizard) || EXIT_STATUS=$$? && \
        (cd libadore && make lizard) || EXIT_STATUS=$$? \ && \
        (cd adore_if_ros && make lizard) || EXIT_STATUS=$$? && \
	    find . -name "**lizard_report.**" -print0 | xargs -0 -I {} mv {} .log/ && \
        exit $$EXIT_STATUS

.PHONY: cppcheck 
cppcheck: ## Run cppcheck static checking tool for all modules.
	find . -name "**cppcheck_report.log" -exec rm -rf {} \;
	EXIT_STATUS=0; \
        (cd sumo_if_ros && make cppcheck) || EXIT_STATUS=$$? && \
        (cd libadore && make cppcheck) || EXIT_STATUS=$$? && \
        (cd adore_if_ros && make cppcheck) || EXIT_STATUS=$$? && \
	    find . -name "**cppcheck_report.log" -print0 | xargs -0 -I {} mv {} .log/ && \
        exit $$EXIT_STATUS

.PHONY: clean_catkin_workspace 
clean_catkin_workspace:
	rm -rf ${CATKIN_WORKSPACE_DIRECTORY}

.PHONY: build_catkin_base 
build_catkin_base: ## Build a docker image with base catkin tools installed with tag catkin_base:latest
	docker build --network host \
	             --file docker/Dockerfile.catkin_base \
                 --tag catkin_base \
                 --build-arg PROJECT=catkin_base .

.PHONY: create_catkin_workspace_docker
create_catkin_workspace_docker: build_catkin_base
	docker run -it \
                   --user "${UID}:${GID}" \
                   --mount type=bind,source=${ROOT_DIR},target=${ROOT_DIR} \
                   catkin_base \
                   /bin/bash -c 'cd ${ROOT_DIR} && HOME=${ROOT_DIR} CATKIN_WORKSPACE_DIRECTORY=${CATKIN_WORKSPACE_DIRECTORY} bash tools/create_catkin_workspace.sh'

.PHONY: create_catkin_workspace
create_catkin_workspace: clean_catkin_workspace## Creates a catkin workspace @ adore/catkin_workspace. Can be called within the adore-cli or on the host.
	echo "USER: ${USER}"
	@if [ "${USER}" == "adore-cli" ]; then\
            bash tools/create_catkin_workspace.sh;\
            exit 0;\
        else\
            make create_catkin_workspace_docker;\
            exit 0;\
        fi;

.PHONY: build_adore-cli
build_adore-cli: build_catkin_base build_plotlabserver ## Builds the ADORe CLI docker context/image
	COMPOSE_DOCKER_CLI_BUILD=1 docker compose build \
                                                     --build-arg UID=${UID} \
                                                     --build-arg GID=${GID} \
                                                     --build-arg DOCKER_GID=${DOCKER_GID}

.PHONY: run_ci_scenarios
run_ci_scenarios:
	bash tools/run_ci_scenarios.txt 

.PHONY: adore-cli
adore-cli: ## Start an adore-cli context
	mkdir -p .log/.ros/bag_files
	mkdir -p .log/plotlabserver
	touch .zsh_history
	touch .zsh_history.new
	[ -n "$$(docker images -q adore-cli:latest)" ] || make build_adore-cli 
	@xhost + && docker compose up --force-recreate -V -d; xhost - 
#	(cd plotlab && make up-detached > /dev/null 2>&1 &);
	docker exec -it --user adore-cli adore-cli /bin/zsh -c "bash tools/adore-cli.sh" || true
	@docker compose down && xhost - 1> /dev/null
	docker compose rm -f
	@cd .log/.ros/log && ln -s -f $$(basename $$(file latest | cut -d" " -f6)) latest 2> /dev/null || true
