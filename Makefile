DATADIR=/usr/local/share/yaptest/
BINDIR=/usr/local/bin/
BINDIR_MAC=/usr/local/bin/
PERLDIR=/usr/local/lib/site_perl
PERLDIR_MAC=/opt/local/lib/perl5/site_perl
YAPTEST_VERSION=`echo yaptest-0.2.1`
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
	./yaptest-install.sh $(BINDIR) $(DATADIR) $(PERLDIR)

installmac:
	./yaptest-install.sh $(BINDIR_MAC) $(DATADIR) $(PERLDIR_MAC)

check:

dist: 
	rm -rf $(YAPTEST_VERSION)
	mkdir $(YAPTEST_VERSION)
	mkdir -p $(YAPTEST_VERSION)/modules/yaptest/lib
	mkdir $(YAPTEST_VERSION)/modules/yaptest/t
	cp modules/yaptest/README $(YAPTEST_VERSION)/modules/yaptest/
	cp modules/yaptest/Changes $(YAPTEST_VERSION)/modules/yaptest/
	cp modules/yaptest/Makefile.PL $(YAPTEST_VERSION)/modules/yaptest/
	cp modules/yaptest/MANIFEST $(YAPTEST_VERSION)/modules/yaptest/
	cp modules/yaptest/t/yaptest.t $(YAPTEST_VERSION)/modules/yaptest/t/
	cp modules/yaptest/lib/yaptest.pm $(YAPTEST_VERSION)/modules/yaptest/lib/yaptest.pm
	cat dist-files.txt | xargs -I FILES cp FILES $(YAPTEST_VERSION)
	tar --owner root --group root -cz -f $(YAPTEST_VERSION).tar.gz $(YAPTEST_VERSION)

clean:
	-rm yaptest-user-docs.pdf
