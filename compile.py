"""
Compile Fortran packages via python
"""

import os


def compile_keplerder(name="keplerder", extension="so", usage="julia"):
	"""Compile keplerder module

	Args:
		name (str): name of compiled executable
		extension (str): extension of executable (e.g. "so", "exe")
		usage (str): compile for uage with "julia" or "python", set to None if not required

	"""
	if usage=="julia":
		os.system(f"gfortran linalg.f90 orbitalelements.f90 keplerder.f90 -o {name}.{extension} -shared -fPIC")
	elif usage=="python":
		os.system(f"f2py -c linalg.f90 orbitalelements.f90 keplerder.f90 -m {name}.{extension}")
		os.system(f"python -m numpy.f2py -c linalg.f90 orbitalelements.f90 keplerder.f90 -m {name}.{extension}")
	elif usage==None:
		os.system(f"gfortran linalg.f90 orbitalelements.f90 keplerder.f90 -o {name}.{extension}")
	else:
		raise ValueError("Set usage to None if not using \"julia\" or \"python\"!")
	return


if __name__=="__main__":
	compile_keplerder()
	print("Done!")