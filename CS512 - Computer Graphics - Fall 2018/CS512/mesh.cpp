#include "mesh.h"
#include "obj_loader.h"
#include <vector>
#include <iostream>

using namespace std;

Mesh::Mesh(const std::string& fileName)
{
	OBJModel obj = OBJModel(fileName);
	model = obj.ToIndexedModel();
	//InitMesh(model); //Œ™mesh…Ë÷√shader

	x_min = model.positions[0][0]; x_max = model.positions[0][0];
	y_min = model.positions[0][1]; y_max = model.positions[0][1];
	z_min = model.positions[0][2]; z_max = model.positions[0][2];
	for (unsigned int i = 0; i < model.positions.size(); i++)
	{
		x_min = (x_min < model.positions[i][0]) ? x_min : model.positions[i][0];
		x_max = (x_max > model.positions[i][0]) ? x_max : model.positions[i][0];
		y_min = (y_min < model.positions[i][1]) ? y_min : model.positions[i][1];
		y_max = (y_max > model.positions[i][1]) ? y_max : model.positions[i][1];
		z_min = (z_min < model.positions[i][2]) ? z_min : model.positions[i][2];
		z_max = (z_max > model.positions[i][2]) ? z_max : model.positions[i][2];
	}

	double eye_opt_x = (x_min + x_max) / 2;
	double eye_opt_y = (y_min + y_max) / 2;
	double delta_x = x_max - x_min; double delta_y = y_max - y_min;
	double dist1 = ((delta_y > delta_x) ? delta_y : delta_x) / sqrt(2);
	double dist2 = (z_max - z_min) * 1.4;
	double dist_z = (dist1 > dist2) ? dist1 : dist2;
	double eye_opt_z = z_max + dist_z;
	eye_opt = glm::vec3(eye_opt_x, eye_opt_y, eye_opt_z);
	lookat_opt = glm::vec3(eye_opt_x, eye_opt_y, (z_min+z_max)/2);
	zNear_opt = float(z_max + dist_z/2);
	zFar_opt = float(z_min - dist_z*100);

	cout << fileName << " is successfully loaded!" << endl;
}

Mesh::~Mesh()
{
	glDeleteVertexArrays(1, &m_vertexArrayObject);
}