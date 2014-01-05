requires 'Class::Accessor::Lite::Lazy', '0.03';
requires 'Class::Load';
requires 'Class::Method::Modifiers';
requires 'String::CamelCase';
requires 'Teng';
requires 'parent';
requires 'perl', '5.008001';

on configure => sub {
    requires 'CPAN::Meta';
    requires 'CPAN::Meta::Prereqs';
    requires 'Module::Build';
};

on test => sub {
    requires 'Test::More', '0.98';
};
