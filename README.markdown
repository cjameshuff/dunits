A framework for handling dimensioned quantities in Ruby.

The Dimensioned class wraps Numeric objects while itself imitating one. You can perform all the usual numeric operations on Dimensioned objects, with additional checking to make sure the operations are sensible given the dimensions of the quantities...you can not add meters and seconds, but you can divide a quantity in meters by one in seconds to get one in meters per second. Un-wrapped numeric values are assumed to be dimensionless, but can otherwise participate in all the usual mathematical operations.

The [] operator is overloaded for Numeric types to allow simple wrapping of numeric values and specification of dimensions:

	b = 5.0[:meter]


Various dimensioned and dimensionless constants are also defined:

	Units.consts[:c] = dim(299792458, :m)/dim(:s)
	Units.consts[:a0] = dim(0.5291772108e-10, :m) # Bohr radius
	Units.consts[:hbar] = dim(1.05457168e-34, :J)*dim(:s) # Reduced Planck constant
	Units.consts[:G] = dim(6.67300e-11, :m3)/dim(:kg)/dim(:s2)
	Units.consts[:gee] = dim(9.80665, :m)/dim(:s2)

