use strict;
use warnings;
use Test::More 0.98;
{
    package Mock::BasicALLINONE;
    use parent 'Teng';
    Mock::BasicALLINONE->load_plugin('ResultSet');
    Mock::BasicALLINONE->load_plugin('Count');

    sub setup_test_db {
        shift->do(q{
            CREATE TABLE mock_basic (
                id   integer,
                name text,
                delete_fg int(1) default 0,
                primary key ( id )
            )
        });
    }
}

{
    package Mock::BasicALLINONE::Schema;
    use utf8;
    use Teng::Schema::Declare;
    schema {
        table {
            name 'mock_basic';
            pk 'id';
            columns qw/
                id
                name
                delete_fg
            /;
        };
    };
}

{
    package Mock::BasicALLINONE::Row::MockBasic;
    use strict;
    use warnings;
    use base 'Teng::Row';
}

my $db = Mock::BasicALLINONE->new(connect_info => ['dbi:SQLite::memory:', '','']);
$db->setup_test_db;

my $rs = $db->result_set('mock_basic');
isa_ok $rs, 'Teng::ResultSet';
isa_ok $rs, 'Mock::BasicALLINONE::ResultSet';
isa_ok $rs, 'Mock::BasicALLINONE::ResultSet::MockBasic';
ok ! exists $rs->{sth};
is $rs->count, 0;

subtest insert => sub {
    $db->result_set('mock_basic')->insert({
        id   => 1,
        name => 'perl',
    });
    my $rs = $db->result_set('mock_basic');
    ok ! exists $rs->{sth};
    is $rs->count, 1;
    my $row = $rs->next;
    ok exists $rs->{sth};

    isa_ok $row, 'Teng::Row';
    is $row->id, 1;
    is $row->name, 'perl';
};

subtest bulk_insert => sub {
    $db->result_set('mock_basic')->bulk_insert([{
        id   => 2,
        name => 'ruby',
    }, {
        id   => 3,
        name => 'python',
    }]);
    my $rs = $db->result_set('mock_basic');
    is $rs->count, 3;

    my $sub_rs = $rs->search({
        id => {'>', 1},
    }, {
        order_by => 'id',
    });
    is $sub_rs->count, 2;
    my $row = $sub_rs->next;
    is $row->id, 2;
    is $row->name, 'ruby';

    my @rows = $rs->search({
        id => {'>', 1},
    }, {
        order_by => 'id',
    });
    is scalar(@rows), 2;

    isa_ok $rows[0], 'Teng::Row';
    is $rows[0]->id, 2;
};

done_testing;
