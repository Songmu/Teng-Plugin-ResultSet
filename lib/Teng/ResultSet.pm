package Teng::ResultSet;
use strict;
use warnings;

use parent 'Teng::Iterator';
use String::CamelCase ();
use Class::Load ();
use Class::Method::Modifiers;
use Class::Accessor::Lite::Lazy (
    ro      => [qw/teng table table_name row_class/],
    rw      => [qw/where opt/],
    ro_lazy => {
        sth => sub {
            my $self = shift;
            my ($sql, @binds) = $self->teng->sql_builder->select(
                $self->table_name,
                $self->teng->_get_select_columns($self->table, $self->opt),
                $self->where,
                $self->opt
            );

            $self->teng->execute($sql, \@binds);
        }
    },
);

{
    my %_CACHE;
    sub new {
        my $class = shift;
        my %args = ref $_[0] ? %{$_[0]}: @_;

        $args{table}     = $args{teng}->schema->get_table($args{table_name})     unless $args{table};
        $args{row_class} = $args{teng}->schema->get_row_class($args{table_name}) unless $args{row_class};

        my $sub_class = $_CACHE{$class}{$args{table_name}} ||= do {
            my $pkg = __PACKAGE__. '::'. String::CamelCase::camelize($args{table_name});
            Class::Load::load_optional_class($pkg) or do {
                no strict 'refs'; @{"$pkg\::ISA"} = __PACKAGE__;
            };
            $pkg;
        };
        bless \%args, $sub_class;
    }
}

sub count {
    my $self = shift;
    $self->teng->count($self->table_name, '*', $self->where, $self->opt);
}

before [qw/all next/] => sub {
    my $self = shift;
    # surely assign sth
    $self->sth;
};

sub search {
    my ($self, $where, $opt) = @_;

    my $new_rs = (ref $self)->new(
        teng  => $self->teng,
        table => $self->table,
        where => {
            %{ $self->where },
            %{ $where || {} },
        },
        opt => {
            %{ $self->opt },
            %{ $opt || {} },
        },
    );
    wantarray ? $new_rs->all : $new_rs;
}

for my $method (qw/find_or_create insert bulk_insert fast_insert search_with_pager delete single find find_for_update/) {
    no strict 'refs';
    *{__PACKAGE__."::$method"} = sub {
        use strict 'refs';
        my $self = shift;

        my $teng = $self->teng;
        unshift @_, $teng, $self->table_name;
        goto $teng->can($method);
    };
}

1;
