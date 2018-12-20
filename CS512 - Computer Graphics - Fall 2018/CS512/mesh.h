#ifndef MESH_INCLUDED_H
#define MESH_INCLUDED_H

#include <GL/glew.h>
#include <glm/glm.hpp>
//#include <string>
//#include <vector>
#include "obj_loader.h"

class Vertex
{
public:
	Vertex(const glm::vec3& pos/*, const glm::vec2& texCoord*/, const glm::vec3& normal = glm::vec3(0,0,0))
	{
		this->pos = pos;
		//this->texCoord = texCoord;
		this->normal = normal;
	}

	inline glm::vec3* GetPos() { return &pos; }
	//inline glm::vec2* GetTexCoord() { return &texCoord; }
	inline glm::vec3* GetNormal() { return &normal; }
protected:
private:
	glm::vec3 pos;
	//glm::vec2 texCoord;
	glm::vec3 normal;
};

class Mesh
{
	public:
		Mesh(const std::string& fileName);

		double x_min, x_max, y_min, y_max, z_min, z_max;
		glm::vec3 eye_opt, lookat_opt;
		float zNear_opt, zFar_opt;
		IndexedModel model;

		virtual ~Mesh();
	protected:
	private:
		//static const unsigned int NUM_BUFFERS = 4;
		//void operator=(const Mesh& mesh) {}
		Mesh(const Mesh& other);

		enum
		{
			POSITION_VB,
			//TEXCOORD_VB,
			NORMAL_VB,
			INDEX_VB,
			NUM_BUFFERS
		};

		GLuint m_vertexArrayObject;
		GLuint m_vertexArrayBuffers[NUM_BUFFERS];
		unsigned int m_drawCount;
};

#endif