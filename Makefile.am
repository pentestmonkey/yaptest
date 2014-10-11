POSTGRES_USER=postgres
POSTGRES_USER_MAC=postgres81
TEMPDIR=/tmp

database: yaptest_template.sql
	touch $(TEMPDIR)/yaptest-db-install.sh
	touch $(TEMPDIR)/yaptest_template.sql
	chown $(POSTGRES_USER) $(TEMPDIR)/yaptest-db-install.sh $(TEMPDIR)/yaptest_template.sql
	chmod 700 $(TEMPDIR)/yaptest-db-install.sh $(TEMPDIR)/yaptest_template.sql
	cp yaptest-db-install.sh $(TEMPDIR)/yaptest-db-install.sh
	cp yaptest_template.sql $(TEMPDIR)/yaptest_template.sql
	su - $(POSTGRES_USER) -c 'sh $(TEMPDIR)/yaptest-db-install.sh $(TEMPDIR)/yaptest_template.sql linux'
	rm $(TEMPDIR)/yaptest-db-install.sh
	rm $(TEMPDIR)/yaptest_template.sql

databasemac: yaptest_template.sql
	touch $(TEMPDIR)/yaptest-db-install.sh
	touch $(TEMPDIR)/yaptest_template.sql
	chown $(POSTGRES_USER_MAC) $(TEMPDIR)/yaptest-db-install.sh $(TEMPDIR)/yaptest_template.sql
	chmod 700 $(TEMPDIR)/yaptest-db-install.sh $(TEMPDIR)/yaptest_template.sql
	cp yaptest-db-install.sh $(TEMPDIR)/yaptest-db-install.sh
	cp yaptest_template.sql $(TEMPDIR)/yaptest_template.sql
	su - $(POSTGRES_USER_MAC) -c 'sh $(TEMPDIR)/yaptest-db-install.sh $(TEMPDIR)/yaptest_template.sql osx'
	rm $(TEMPDIR)/yaptest-db-install.sh
	rm $(TEMPDIR)/yaptest_template.sql

checkdep:
	./yaptest-check-dependencies.sh

install:
	./yaptest-install.sh

# need to work out if we can simply use autoconf's dist creator
#dist: 
#	rm -rf $(YAPTEST_VERSION)
#	mkdir $(YAPTEST_VERSION)
#	mkdir -p $(YAPTEST_VERSION)/modules/yaptest/lib
#	mkdir $(YAPTEST_VERSION)/modules/yaptest/t
#	cp modules/yaptest/README $(YAPTEST_VERSION)/modules/yaptest/
#	cp modules/yaptest/Changes $(YAPTEST_VERSION)/modules/yaptest/
#	cp modules/yaptest/Makefile.PL $(YAPTEST_VERSION)/modules/yaptest/
#	cp modules/yaptest/MANIFEST $(YAPTEST_VERSION)/modules/yaptest/
#	cp modules/yaptest/t/yaptest.t $(YAPTEST_VERSION)/modules/yaptest/t/
#	cp modules/yaptest/lib/yaptest.pm.in $(YAPTEST_VERSION)/modules/yaptest/lib/yaptest.pm.in
#	cat dist-files.txt | xargs -I FILES cp F).tar.gz $(YAPTEST_VERSION)

clean:
	rm -rf autom4te.cache config.status config.log Makefile yaptest.conf modules/yaptest/Makefile modules/yaptest/Makefile.old modules/yaptest/MYMETA.yml modules/yaptest/lib/yaptest.pm modules/yaptest/pm_to_blib modules/yaptest/blib
