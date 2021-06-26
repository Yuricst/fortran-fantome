"""
Compile Fortran packages via python
"""

import os


def compile_keplerder(name="keplerder", extension="so", usage="julia", compiler="gfortran"):
	"""Compile keplerder module

	Args:
		name (str): name of compiled executable
		extension (str): extension of executable (e.g. "so", "exe")
		usage (str): compile for uage with "julia" or "python", set to None if not required
		compiler (str): fortran compiler (e.g. "gfortran")

	"""
	print(f"Compiling {name}.{extension} ...")
	if usage=="julia":
		os.system(f"{compiler} linalg.f90 orbitalelements.f90 keplerder.f90 -o {name}.{extension} -shared -fPIC")
	elif usage=="python":
		os.system(f"f2py -c linalg.f90 orbitalelements.f90 keplerder.f90 -m {name}.{extension}")
		os.system(f"python -m numpy.f2py -c linalg.f90 orbitalelements.f90 keplerder.f90 -m {name}.{extension}")
	elif usage==None:
		os.system(f"{compiler} linalg.f90 orbitalelements.f90 keplerder.f90 -o {name}.{extension}")
	else:
		raise ValueError("Set usage to None if not using \"julia\" or \"python\"!")
	return


def compile_fantome(name="fantome", extension="so", usage="julia", compiler="gfortran"):
	"""Compile keplerder module

	Args:
		name (str): name of compiled executable
		extension (str): extension of executable (e.g. "so", "exe")
		usage (str): compile for uage with "julia" or "python", set to None if not required

	"""
	print(f"Compiling {name}.{extension} ...")
	if usage=="julia":
		os.system(f"{compiler} linalg.f90 orbitalelements.f90 keplerder.f90 fantome.f90 -o {name}.{extension} -shared -fPIC")
	elif usage=="python":
		os.system(f"f2py -c linalg.f90 orbitalelements.f90 keplerder.f90 fantome.f90  -m {name}.{extension}")
		os.system(f"python -m numpy.f2py -c linalg.f90 orbitalelements.f90 keplerder.f90 fantome.f90  -m {name}.{extension}")
	elif usage==None:
		os.system(f"{compiler} linalg.f90 orbitalelements.f90 keplerder.f90 fantome.f90 -o {name}.{extension}")
	else:
		raise ValueError("Set usage to None if not using \"julia\" or \"python\"!")
	return


if __name__=="__main__":
	compile_fantome()
	print("Done!")