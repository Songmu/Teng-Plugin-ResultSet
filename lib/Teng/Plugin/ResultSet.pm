package Teng::Plugin::ResultSet;
use 5.008001;
use strict;
use warnings;

our $VERSION = "0.01";

use Class::Load;
use String::CamelCase qw/decamelize/;

use Teng::ResultSet;
our @EXPORT = qw/resultset/;

{
    my %_CACHE;
    sub resultset {
        my ($self, $table_name) = @_;

        $table_name = decamelize $table_name;
        my $teng_class = ref $self;
        my $result_set_class = $_CACHE{$teng_class} ||= do {
            my $rs_class = "$teng_class\::ResultSet";
            Class::Load::load_optional_class($rs_class) or do {
                # make result_class class automatically
                no strict 'refs'; @{"$rs_class\::ISA"} = ('Teng::ResultSet');
            };
            $rs_class;
        };
        $result_set_class->new(teng => $self, table_name => $table_name);
    }
}

1;
__END__

=encoding utf-8

=head1 NAME

Teng::Plugin::ResultSet - It's new $module

=head1 SYNOPSIS

    use Teng::Plugin::ResultSet;

=head1 DESCRIPTION

Teng::Plugin::ResultSet is ...

=head1 LICENSE

Copyright (C) Songmu.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Songmu E<lt>y.songmu@gmail.comE<gt>

=cut

