package Games::Go::SGF;

use 5.006;
use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);
our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
our @EXPORT = qw(
	
);
our $VERSION = '0.01';


use Parse::RecDescent;
my $grammar = q{
    GameTree  : "(" Sequence GameTree(s?) ")"
                { $return = $item[2]; if(@{$item[3]}) {push @$return, bless $item[3], "Games::Go::SGF::Variation"} }
    Sequence  : Node(s)
    Node      : ";" Property(s)
                { $return = bless { map {@$_} @{$item[2]} }, "Games::Go::SGF::Node"; }
    Property  : PropIdent PropValue(s)
                { if (@{$item[2]} ==1 ) { $item[2]=$item[2][0] } $return = [$item[1], $item[2] ] }
    PropIdent : /[A-Z]+/
    PropValue : "[" CValueType "]"
                { $return = $item[2]; chomp $return; } 
    CValueType: ValueType | Compose
    ValueType : SimpleText 
    Compose   : ValueType ":" ValueType
    SimpleText: /[^\[\]]*/ "[" SimpleText "]" SimpleText
                { $return = join "", @item[1..@item]; }
                | /[^\[\]]*/ 

};
my $parser = new Parse::RecDescent $grammar;
use Carp;

sub new {
    my $class = shift;
    my $a = $parser->GameTree(shift) or croak "Couldn't parse SGF file\n";
    bless $a, "Games::Go::SGF";
    _sew($a);
    return $a;
} 

sub _sew {
    my $a = shift;
    $a->[0]->{moves_to_first_variation} = 0;
    for (0..@$a) { 
        if (ref $a->[$_] eq "Games::Go::SGF::Variation") {
           $a->[0]->{moves_to_first_variation} ||= $_;
           _sew($_) for $a->[$_]->variations;
        } else {
            $a->[$_]->{next} = $a->[$_+1];
        }
    }
}

# Game info methods
sub date  { shift->[0]->{DT}; }
sub time  { shift->[0]->{DT}; }
sub white { shift->[0]->{PW}; }
sub black { shift->[0]->{PB}; }
sub size  { shift->[0]->{SZ}; }
sub komi  { shift->[0]->{KM}; }
sub move  { $_[0]->[$_[1]];   }

package Games::Go::SGF::Variation; 
our $AUTOLOAD;
sub mainline   { return $_[0]->[0] }
sub variation  { return $_[0]->[$_[1]] }
sub variations { return @{$_[0]} }

# This is - as I shouldn't need to tell you - is a dirty hack.
# But I like it.
sub AUTOLOAD {
    $AUTOLOAD=~ s/Variation/Node/;
    &$AUTOLOAD($_[0]->mainline, @_[1..@_]);
}

package Games::Go::SGF::Node;
sub move  { my $node = shift; $node->{B} || $node->{W} }

# Preloaded methods go here.

1;
__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

Games::Go::SGF - Parse and dissect Standard Go Format files

=head1 SYNOPSIS

  use Games::Go::SGF;
  my $sgf = new Games::Go::SGF($sgfdata);
  print "Game played on ".$sgf->date."\n";
  print $sgf->white. " (W) vs. ".$sgf->black." (B)\n";
  print "Board size: ".$sgf->size.". Komi: ".$sgf->komi."\n";

  while ($move = $sgf->move($move_no++)) {
    print "$move_no: ".$move->move,"\n";
  }

=head1 DESCRIPTION

This is a very simple SGF file parser, of currently limited
functionality. It can read and step through SGF files, follow
variations, and so on. It's good enough for getting simple
statistics about games of Go, and building up C<Games::Go::Board>
objects representing games stored as SGF.

C<< $sgf->move >> returns either a normal C<Games::Go::SGF::Node>
or a C<Games::Go::SGF::Variation> object. They behave exactly
the same, but the variation object has the additional methods
C<mainline()> to get the main line of the game, C<variation($n)>
to get the first node in the n'th variation, and C<variations>
to retrieve an array of variations. C<< $variation->move >> will,
by default, follow the mainline.

=head1 TODO

Better documentation is planned; as is the ability to write
as well as read SGF files.

=head1 AUTHOR

Simon Cozens C<simon@cpan.org>

=head1 SEE ALSO

L<Games::Go::Board>, http://www.red-bean.com/sgf/

=cut
