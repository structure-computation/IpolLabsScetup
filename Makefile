LIBRARIES = \
	METIL-lang \
	Metil \
	Soca \
	Soda \
	Soja \
	Celo \
	Sipe \
	PrepArg \
	IpolLabs \
	IpolPlugins
	
BRANCHES = \
	IpolLabs,master \
	Soja,master \
	Soda,master \
	Celo,master \
	Sipe,master \
	PrepArg,master \
	IpolPlugins,master

	
	
SYM_LINKS = \
	IpolLabs,Javascript \
	IpolPlugins,IpolPlugins \
	IpolPlugins/IpolACEPlugin/OnlinePugin/IpolACE,software_library/IpolLabs/plugins/IpolACE \
	IpolPlugins/IpolSCAPlugin/OnlinePugin/IpolSCA,software_library/IpolLabs/plugins/IpolSCA \
	IpolPlugins/IpolLSDPlugin/OnlinePugin/IpolLSD,software_library/IpolLabs/plugins/IpolLSD \
	IpolPlugins/IpolTVDPlugin/OnlinePugin/IpolTVD,software_library/IpolLabs/plugins/IpolTVD \
	Soja,software_library/IpolLabs/ext/Soja \
	Soda,software_library/IpolLabs/ext/Soda \
	Celo,software_library/Soda/ext/Celo \
	Sipe,software_library/Soda/ext/Sipe \
	PrepArg,software_library/Soda/ext/PrepArg

	
	
SHELL = /bin/bash
	
all: compilation
	which easy_install || sudo apt-get install easy_install
	python -c "import ramona" || sudo easy_install ramona
	# ==========================================================
	# Lancement de ramona -> http://localhost:5588
	# ==========================================================
	./ram.py server

compilation: sym_links
	which metil_comp || make -C software_library/Metil install
	make -C software_library/IpolPlugins/IpolACEPlugin
	make -C software_library/IpolPlugins/IpolSCAPlugin
	make -C software_library/IpolPlugins/IpolLSDPlugin
	make -C software_library/IpolPlugins/IpolTVDPlugin
	make -C software_library/IpolLabs Soja_javascripts
	
	
soda_server: compilation
	make -C Javascript mechanic

plugins: compilation
	make -C software_library/IpolPlugins/GlobalManagerPlugin
	
plugins_with_sleep: compilation
	sleep 5
	make plugins


software_library:
	mkdir software_library
	
prereq: software_library
	# ========================= CLONING IF NECESSARY =========================
	for i in ${LIBRARIES}; do test -e software_library/$$i || git clone git@github.com:structure-computation/$$i software_library/$$i; done

pull:
	for i in ${LIBRARIES}; do \
		pushd software_library/$$i; \
		git pull; \
		popd; \
	done

push:
	for i in ${LIBRARIES}; do \
		pushd software_library/$$i; \
		git commit -a; \
		git push; \
		popd; \
	done

branches: prereq
	# ========================= SETTING BRANCHES =========================
	for i in ${BRANCHES}; do \
		R=`echo $$i | sed 's/\\(.*\\),.*/\\1/'`; \
		B=`echo $$i | sed 's/.*,\\(.*\\)/\\1/'`; \
		pushd software_library/$$R; \
		git checkout -b $$B origin/$$B 2> /dev/null || git checkout $$B; \
		popd; \
	done
	
sym_links: prereq
	# ========================= SYMBOLIC LINKS =========================
	for i in ${SYM_LINKS}; do \
		R=`echo $$i | sed 's/\\(.*\\),.*/\\1/'`; \
		B=`echo $$i | sed 's/.*,\\(.*\\)/\\1/'`; \
		mkdir -p `dirname $$B`; \
		test -e $$B || ln -s `pwd`/software_library/$$R $$B; \
	done

#  		test -e $$B && ( test -h $$B || ( echo $$B SHOULD BE A SYMLINK -- GOING TO DELETE IT; read ) ) ; \
# 		rm $$B; \

# 
# Dans scills
# ln -s ../scult/src/GEOMETRY src/GEOMETRY 
# ln -s ../scult/src/COMPUTE src/COMPUTE 
# ln -s ../scult/src/UTILS src/UTILS
# mkdir UTIL
# cd UTIL ; ln -s ../../metis-4 metis ; ln -s /usr/include/openmpi openmpi


.PHONY: prereq branches sym_links server compilation
