
require 'dunits/dimensioned'

module Units
    @units = {} # units by name
    @unit_names = {} # unit names by dimensions
    @consts = {}
    
    SI_PREFIX_ALIASES = {
        yotta: :yotta,
        Y: :yotta,
        zetta: :zetta,
        Z: :zetta,
        exa: :exa,
        E: :exa,
        peta: :peta,
        P: :peta,
        tera: :tera,
        T: :tera,
        giga: :giga,
        G: :giga,
        mega: :mega,
        M: :mega,
        kilo: :kilo,
        k: :kilo,
        hecto: :hecto,
        h: :hecto,
        deca: :deca,
        da: :deca,
        
        deci: :deci,
        d: :deci,
        centi: :centi,
        c: :centi,
        milli: :milli,
        m: :milli,
        micro: :micro,
        nano: :nano,
        n: :nano,
        pico: :pico,
        p: :pico,
        femto: :femto,
        f: :femto,
        atto: :atto,
        a: :atto,
        zepto: :zepto,
        z: :zepto,
        yocto: :yocto,
        y: :yocto
    }
    SI_PREFIX_ALIASES["\u03BC"] = :micro, # Unicode lower-case mu
    SI_PREFIX_ALIASES["\u00B5"] = :micro, # Unicode "micro sign"
    SI_PREFIX_ALIAS_NAMES = SI_PREFIX_ALIASES.keys
    
    SI_PREFIX_PWRS = {
        yotta: 24,
        zetta: 21,
        exa: 18,
        peta: 15,
        tera: 12,
        giga: 9,
        mega: 6,
        kilo: 3,
        hecto: 2,
        deca: 1,
        
        deci: -1,
        centi: -2,
        milli: -3,
        micro: -6,
        nano: -9,
        pico: -12,
        femto: -15,
        atto: -18,
        zepto: -21,
        yocto: -24
    }
    
    SI_PREFIX_MULS = SI_PREFIX_PWRS.keys.inject({}) {|muls, pwr| muls[pwr] = 10**SI_PREFIX_PWRS[pwr]; muls}
    
    
    def Units.consts()
        @consts
    end
    
    def Units.units()
        @units
    end
    
    # TODO: handle instances where multiple units can share a name
    def Units.def_unit(name, dunit, family)
        @units[name.to_sym] = {dim: dunit, family: family, abbrevs: []}
        @unit_names[dunit.dimensions] = name
    end
    def Units.def_unit_alias(name, base)
        @units[name.to_sym] = @units[base.to_sym]
    end
    def Units.def_unit_abbrev(name, base)
        @units[base.to_sym][:abbrevs].push(name.to_sym)
        @units[name.to_sym] = @units[base.to_sym]
    end
    
    def Units.lookup_unit(unit_name)
        unit_name = unit_name.to_s
        unit_sym = unit_name.to_sym
        # Look for match with full name.
        match = @units[unit_sym]
        if(match)
            return match[:dim]
        end
        
        # If no direct matches work, try a prefix-unit combination
        # Find all multiplier prefixes that unit name begins with
        pfxs = SI_PREFIX_ALIAS_NAMES.find_all {|a| unit_name.start_with?(a.to_s)}
        # Return nil if no prefix
        if(pfxs.empty?)
            return nil
        end
        
        # If any prefixes match, look for units with remainder as name, trying each matched prefix
        # until a full match is found.
        matches = []
        pfxs.each{|pfx|
            unit_sym = unit_name[pfx.length, unit_name.length].to_sym
            part_matches = @units[unit_sym]
            if(part_matches)
                matches.push([pfx, part_matches])
            end
        }
        
        # No attempt made to handle units with same name at present
        if(matches.empty?)
            raise "No match found for unit: #{unit_name}"
        end
        if(matches.length > 1)
            raise "Ambiguous unit string: #{unit_name}"
        end
        pfx = matches[0][0]
        unit = matches[0][1][:dim]
        mul = SI_PREFIX_MULS[SI_PREFIX_ALIASES[pfx]]
        unit*mul
    end
    
    def Units.to_s_si(value, opts = {})
        # options: :long
        # TODO
        # Use SI base and derived units to express value. Prefer a direct match or
        # "common combination", but otherwise use a generic representation in base units.
        # Set prefixes to appropriate size, attempting to keep numeric value in range +-0-999.
        # If there are multiple dimensions and no common combination matches, adjust
        # prefixes in this order: meter, kilogram, ampere, ...
    end
    
    # Define base units.
    # kilogram is the actual base unit for deriving other units, but gram
    # is the unit defined to make handling prefixes easier.
    one =       Dimensioned.new(1, [0, 0, 0, 0, 0, 0, 0])
    radian =    Dimensioned.new(1, [0, 0, 0, 0, 0, 0, 0])
    steradian = Dimensioned.new(1, [0, 0, 0, 0, 0, 0, 0])
    meter =    Dimensioned.new(1, [1, 0, 0, 0, 0, 0, 0])
    kg =       Dimensioned.new(1, [0, 1, 0, 0, 0, 0, 0])
    gram =     Dimensioned.new(1.0/1000, [0, 1, 0, 0, 0, 0, 0])
    second =   Dimensioned.new(1, [0, 0, 1, 0, 0, 0, 0])
    kelvin =   Dimensioned.new(1, [0, 0, 0, 1, 0, 0, 0])
    ampere =   Dimensioned.new(1, [0, 0, 0, 0, 1, 0, 0])
    candela =  Dimensioned.new(1, [0, 0, 0, 0, 0, 1, 0])
    mol =      Dimensioned.new(1, [0, 0, 0, 0, 0, 0, 1])
    
    def_unit(:meter, meter, :si)
    def_unit(:gram, gram, :si)
    def_unit(:second, second, :si)
    def_unit(:kelvin, kelvin, :si)
    def_unit(:ampere, ampere, :si)
    def_unit_alias(:amp, :ampere)
    def_unit(:candela, candela, :si)
    def_unit(:mol, mol, :si)
    def_unit_alias(:mole, :mol)
    def_unit(:radian, radian, :si)
    def_unit(:steradian, steradian, :si)
    
    
    def_unit_abbrev(:s, :second)
    def_unit_abbrev(:m, :meter)
    def_unit_abbrev(:g, :gram)
    def_unit_abbrev(:K, :kelvin)
    def_unit_abbrev(:A, :ampere)
    def_unit_abbrev(:cd, :candela)
    def_unit_abbrev(:rad, :radian)
    def_unit_abbrev(:sr, :steradian)
    
    # Derived units
    m = meter
    m2 = m*m
    def_unit(:m2, m2, :si)
    def_unit(:m3, m*m*m, :si)
    
    s = second
    s2 = s*s
    def_unit(:s2, s2, :si)
    
    newton = kg*m/s2
    joule = newton*m
    coulomb = s*ampere
    volt = joule/coulomb
    
    def_unit(:hertz, one/s, :si)
    def_unit(:newton, kg*m/s2, :si)
    def_unit(:pascal, newton/m2, :si)
    def_unit(:joule, joule, :si)
    def_unit(:watt, joule/s, :si)
    def_unit(:coulomb, coulomb, :si)
    def_unit(:volt, volt, :si)
    def_unit(:farad, coulomb/volt, :si)
    def_unit(:ohm, volt/ampere, :si)
    def_unit(:siemens, ampere/volt, :si)
    
    weber = joule/ampere
    def_unit(:weber, weber, :si)
    def_unit(:tesla, weber/m2, :si)
    def_unit(:henry, weber/ampere, :si)
    
    def_unit(:lumen, candela, :si) # cd/sr
    def_unit(:lux, candela/m2, :si) # lm/m^2
    
    def_unit(:becquerel, one/s, :si)
    def_unit(:gray, joule/kg, :si)
    def_unit(:sievert, joule/kg, :si)
    def_unit(:katal, mol/s, :si)
    
    
    def_unit_abbrev(:Hz, :hertz)
    def_unit_abbrev(:N, :newton)
    def_unit_abbrev(:Pa, :pascal)
    def_unit_abbrev(:J, :joule)
    def_unit_abbrev(:W, :watt)
    def_unit_abbrev(:C, :coulomb)
    def_unit_abbrev(:V, :volt)
    def_unit_abbrev(:F, :farad)
    # def_unit_abbrev(:, :ohm)
    def_unit_abbrev(:S, :siemens)
    def_unit_abbrev(:Wb, :weber)
    def_unit_abbrev(:T, :tesla)
    def_unit_abbrev(:H, :henry)
    def_unit_abbrev(:lm, :lumen)
    def_unit_abbrev(:lx, :lux)
    def_unit_abbrev(:Bq, :becquerel)
    def_unit_abbrev(:Gy, :gray)
    def_unit_abbrev(:Sv, :sievert)
    def_unit_abbrev(:kat, :katal)
    
    
    # TODO: http://en.wikipedia.org/wiki/Non-SI_units_accepted_for_use_with_SI
    def_unit(:liter, Dimensioned.new(0.001, [3, 0, 0, 0, 0, 0, 0]), :si)
    def_unit_abbrev(:L, :liter)
    
    def_unit(:tonne, dim(1000, :kg), :si)
    def_unit_abbrev(:t, :tonne)
    
    def_unit(:micron, dim(1/1000, :m), :si)
    
    def_unit(:t_TNT, dim(4.184e9, :J), :si)
    def_unit_alias(:t_tnt, :t_TNT)
    def_unit(:g_TNT, dim(4.184e3, :J), :si)
    def_unit_alias(:g_tnt, :g_TNT)
    
    def_unit(:minute, dim(60.0, :s), :std)
    def_unit(:hour, dim(60, :minute), :std)
    def_unit(:day, dim(24, :hour), :std)
    def_unit(:week, dim(7, :day), :std)
    def_unit(:year, dim(31556926, :s), :std)
    def_unit(:month, dim(1.0/12, :year), :std)
    
    def_unit(:atm, dim(101325, :pascal), :std)
    def_unit(:bar, dim(100000, :pascal), :std)
    def_unit(:torr, dim(133.322, :pascal), :std)
    def_unit(:psi, dim(6895, :pascal), :imp)
    
    def_unit(:electron_volt, dim(1.60217653e-19, :J), :std)
    def_unit(:degree, dim(Math::PI/180), :std)
    
    def_unit(:inch, dim(0.0254, :m), :imp)
    def_unit_abbrev(:in, :inch)
    def_unit(:foot, dim(12, :in), :imp)
    def_unit_abbrev(:ft, :foot)
    def_unit(:yard, dim(3, :ft), :imp)
    def_unit_abbrev(:yd, :yard)
    def_unit(:mile, dim(1760, :yd), :imp)
    def_unit_abbrev(:mi, :mile)
    
    
    Units.consts[:c] = dim(299792458, :m)/dim(:s)
    Units.consts[:G] = dim(6.67300e-11, :m3)/dim(:kg)/dim(:s2)
    Units.consts[:gee] = dim(9.80665, :m)/dim(:s2)
    
    c = Units.consts[:c]
    def_unit(:light_second, c*dim(1, :s), :std)
    def_unit(:light_minute, c*dim(1, :minute), :std)
    def_unit(:light_hour, c*dim(1, :hour), :std)
    def_unit(:light_week, c*dim(1, :week), :std)
    def_unit(:light_month, c*dim(1, :month), :std)
    def_unit(:light_year, c*dim(1, :year), :std)
    def_unit(:parsec, dim(3.08568025e16, :m), :std)
end # module Units
