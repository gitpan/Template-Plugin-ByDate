package Template::Plugin::ByDate;

use warnings;
use strict;

=head1 NAME

Template::Plugin::ByDate - Keeps/removes included text based on whether the
    current date is within range.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

    [% USE ByDate %]
    
    [% FILTER ByDate
         starting = '2006-05-02'
         until = '2006-08-22' %]
    This text only shows up from May 2, 2006 through August 22, 2006.
    [% END %]

=head1 FUNCTIONS

=head2 init

=cut

use base 'Template::Plugin::Filter';

sub init
{
    my $self = shift;
    $self->{ _DYNAMIC }++;
    $self->install_filter($self->{_ARGS}->[0] || 'ByDate');
    $self;
}

=head2 filter

We accept one optional argument, the word "not".  If specified, it will
reverse the meaning of the filter: rather than keeping the text if the current
date is between starting and until, ignore it.  e.g.,

    [% FILTER ByDate
        starting = '2006-05-02'
        until = '2006-08-22' %]
    This only shows up inside the date range
    [% END %]

while

    [% FILTER ByDate
        'not' starting = '2006-05-02'
        until = '2006-08-22' %]
    This only shows up outside the date range
    [% END %]


=cut

use Date::Parse;

sub _any(&@) {
    my $code = shift;
    $code->() && return 1 for @_;
    0
}

sub filter
{
    my ($self, $text, $args, $conf) = @_;

    $args = $self->merge_args($args);
    $conf = $self->merge_config($conf);

    my $not = _any { lc eq 'not'} @$args;

    my $starting = exists $conf->{starting} ? str2time($conf->{starting}) : 0;
    my $until    = exists $conf->{'until'} ?  str2time($conf->{'until'})  : undef;
    my $now      = exists $conf->{now} ?      str2time($conf->{now})      : time;

    my $display = $now >= $starting ? 1 : 0;
    if (defined $until)
    {
        $display = 0 unless $until >= $now;
    }

    $display = $display ^ $not;
    $display ? $text : '';
}

=head1 AUTHOR

Darin McBride, C<< <dmcbride at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-template-plugin-bydate at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Template-Plugin-ByDate>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Template::Plugin::ByDate

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Template-Plugin-ByDate>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Template-Plugin-ByDate>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Template-Plugin-ByDate>

=item * Search CPAN

L<http://search.cpan.org/dist/Template-Plugin-ByDate>

=back

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2006 Darin McBride, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of Template::Plugin::ByDate
