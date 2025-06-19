classdef Seeding
  methods(Static)

    function env = check_octave()
      if exist('OCTAVE_VERSION', 'builtin') == 5
          env = 1;%'Octave';
      else
          env = 0;%'MATLAB';
      end
    end
    #first issue is that matlab and octave seed differently,
    #we are primarily focusing on octave, but a function has been written
    #that will make a 'matlab seed' work in octave, so we will include here
    #that way if someone wants to convert the code to matlab they canonicalize_file_name
    #(it is mosly just replacing all pattern of 'end*' to 'end%*'
    #https://wiki.octave.org/wiki/index.php?title=User:Markuman&mobileaction=toggle_view_desktop
    function ret = twister_seed(SEED=0)

       ret = uint32(zeros(625,1));
       ret(1) = SEED;
       for N = 1:623
           ## initialize_generator
           # bit-xor (right shift by 30 bits)
           uint64(1812433253)*uint64(bitxor(ret(N),bitshift(ret(N),-30)))+N; # has to be uint64, otherwise in 4th iteration hit maximum of uint32!
           ret(N+1) = uint32(bitand(ans,uint64(intmax('uint32')))); # untempered numbers
       end%for
       ret(end) = 1;

    end%function
    function Seed(SEED)
      %'twister_seed' converts (octave, python) to match (numpy, ruby, matlab)

      if Seeding.check_octave()
        S=Seeding.twister_seed( SEED);
      else
        S=SEED;
      end
      rand('twister', S);
      randn('twister', S);

    end%function
  end%methods
end%classdef

