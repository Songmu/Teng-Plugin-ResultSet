requires 'Class::Accessor::Lite::Lazy';
requires 'Class::Load';
requires 'Class::Method::Modifiers';
requires 'String::CamelCase';
requires 'Teng::Iterator';
requires 'parent';
requires 'perl', '5.008001';

on configure => sub {
    requires 'CPAN::Meta';
    requires 'CPAN::Meta::Prereqs';
    requires 'Module::Build';
};

on test => sub {
    requires 'Teng';
    requires 'Teng::Row';
    requires 'Teng::Schema::Declare';
    requires 'Test::More', '0.98';
};
