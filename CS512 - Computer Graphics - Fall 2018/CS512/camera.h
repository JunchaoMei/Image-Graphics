#ifndef CAMERA_INCLUDED_H
#define CAMERA_INCLUDED_H
#define GLM_ENABLE_EXPERIMENTAL

#include <glm/glm.hpp>
#include <glm/gtx/transform.hpp>
#include <iostream>
#include <math.h>
#include "display.h"
#include "mesh.h"

extern Mesh* mesh_pt;
extern float fov_main;
extern float aspect_main;

using namespace std;

class Camera
{
	public:
		GLfloat projectMat[16];
		float fovy;
		float aspect;
		float zNear;
		float zFar;

		GLfloat viewMat[16];
		glm::vec3 eye;
		glm::vec3 lookat;
		glm::vec3 cam_x;
		glm::vec3 cam_y; //up
		glm::vec3 cam_z;

		//constructor
		Camera(float zNear_input, float zFar_input, glm::vec3 eye_input, glm::vec3 lookat_input)
		{
			fovy = fov_main;
			aspect = aspect_main;
			zNear = zNear_input;
			zFar = zFar_input;
			setProjectMat(fovy, aspect, zNear, zFar);

			eye = eye_input;
			lookat = lookat_input;
			cam_x = glm::vec3(1, 0, 0);
			cam_y = glm::vec3(0, 1, 0); //up
			cam_z = glm::vec3(0, 0, 1);
			setViewMat(eye, lookat, cam_y);

			printCamInfo();
		}

		void printCamInfo()
		{
			cout << endl << "[Camera Settings]" << endl;
			cout << "Field of View in Y-axis: " << fovy << "°" << endl;
			cout << "Aspect (width/height of window): " << aspect << endl;
			cout << "Near Clipping: z=" << zNear << endl;
			cout << "Far Clipping: z=" << zFar << endl;
			cout << "Eye: (" << eye[0] << ", " << eye[1] << ", " << eye[2] << ")" << endl;
			cout << "LookAt: (" << lookat[0] << ", " << lookat[1] << ", " << lookat[2] << ")" << endl;
			cout << "Up: (" << cam_y[0] << ", " << cam_y[1] << ", " << cam_y[2] << ")" << endl << endl;
		}

		void setProjectMat(float fovy, float aspect, float zNear, float zFar)
		{
			float n = zNear; float f = zFar;
			float t = n * tan(glm::radians(fovy/2)); float b = -t;
			float r = aspect * t; float l = -r;
			projectMat[0]=(2*n)/(r-l); projectMat[4]=0; projectMat[8]=(r+l)/(r-l); projectMat[12]=0;
			projectMat[1]=0; projectMat[5]=(2*n)/(t-b); projectMat[9]=(t+b)/(t-b); projectMat[13]=0;
			projectMat[2]=0; projectMat[6]=0; projectMat[10]=-(f+n)/(f-n); projectMat[14]=-(2*f*n)/(f-n);
			projectMat[3]=0; projectMat[7]=0; projectMat[11]=-1; projectMat[15]=0;
			
			// =====test=====
			//printGLfloatArray(projectMat);
		}

		void setViewMat(glm::vec3 eye, glm::vec3 lookat, glm::vec3 up)
		{
			glm::vec3 n = glm::normalize(eye-lookat);
			glm::vec3 u = glm::cross(cam_y, n);
			glm::vec3 v = glm::cross(n, u);
			glm::vec3 Oc = eye;

			viewMat[0]=u[0]; viewMat[4]=u[1]; viewMat[8]=u[2]; viewMat[12]=-glm::dot(Oc,u);
			viewMat[1]=v[0]; viewMat[5]=v[1]; viewMat[9]=v[2]; viewMat[13]=-glm::dot(Oc, v);
			viewMat[2]=n[0]; viewMat[6]=n[1]; viewMat[10]=n[2]; viewMat[14]=-glm::dot(Oc, n);
			viewMat[3]=0; viewMat[7]=0; viewMat[11]=0; viewMat[15]=1;

			// =====test=====
			//printGLfloatArray(viewMat);
		}

		void camTrans(char alongAxis, char axis)
		{
			float dist;
			glm::vec3 direc;

			std::cout << std::endl << "Translating Distance (negative number for opposite direction) = ";
			std::cin >> dist;

			if (alongAxis == 'y')
			{
				switch (axis)
				{
					case 'x':
						direc = cam_x;
						break;
					case 'y':
						direc = cam_y;
						break;
					case 'z':
						direc = cam_z;
						break;
					default:
						break;
				}
			} else
			{
				float direc_x, direc_y, direc_z;
				std::cout << "Please input the x,y,z components of the Unit Distance Vector, separated by space:  ";
				std::cin >> direc_x >> direc_y >> direc_z;
				direc = glm::vec3(direc_x, direc_y, direc_z);
			}
	
			eye += dist * direc;
			lookat += dist * direc;

			//update camera
			setProjectMat(fovy, aspect, zNear, zFar);
			setViewMat(eye, lookat, cam_y);
			printCamInfo();
		}

		void camRotate(char alongAxis, char axis)
		{
			float angle;
			glm::vec3 rotAxis;
			glm::vec3 Nold = eye - lookat;

			std::cout << std::endl << "Rotating Angle = ";
			std::cin >> angle;

			if (alongAxis == 'y')
			{
				switch (axis)
				{
					case 'x':
						rotAxis = cam_x;
						break;
					case 'y':
						rotAxis = cam_y;
						break;
					case 'z':
						rotAxis = cam_z;
						break;
					default:
						break;
				}
			} else
			{
				float direc_x, direc_y, direc_z;
				std::cout << "Please input the x,y,z components of the Rotating Axis Vector, separated by space:  ";
				std::cin >> direc_x >> direc_y >> direc_z;
				rotAxis = glm::vec3(direc_x, direc_y, direc_z);
			}

			glm::mat4 rotMatrix = glm::rotate(glm::radians(angle), rotAxis);
						
			//xyz三个轴需要同时旋转
			glm::vec4 old_x = glm::vec4(cam_x[0], cam_x[1], cam_x[2], 1);
			glm::vec4 new_x = rotMatrix * old_x;
			cam_x = glm::vec3(new_x[0], new_x[1], new_x[2]);
			glm::vec4 old_y = glm::vec4(cam_y[0], cam_y[1], cam_y[2], 1);
			glm::vec4 new_y = rotMatrix * old_y;
			cam_y = glm::vec3(new_y[0], new_y[1], new_y[2]);
			glm::vec4 old_z = glm::vec4(cam_z[0], cam_z[1], cam_z[2], 1);
			glm::vec4 new_z = rotMatrix * old_z;
			cam_z = glm::vec3(new_z[0], new_z[1], new_z[2]);

			//法向N 旋转
			glm::vec4 old_N = glm::vec4(Nold[0], Nold[1], Nold[2], 1);
			glm::vec4 new_N = rotMatrix * old_N;
			glm::vec3 Nnew = glm::vec3(new_N[0], new_N[1], new_N[2]);
			lookat = eye - Nnew;

			//update camera
			setProjectMat(fovy, aspect, zNear, zFar);
			setViewMat(eye, lookat, cam_y);
			printCamInfo();
		}

		void camClip(char plane)
		{
			float zPosition;

			std::cout << std::endl << "new position: z = ";
			std::cin >> zPosition;

			if (plane == 'n')
				zNear = zPosition;
			else if (plane == 'f')
				zFar = zPosition;

			//update camera
			setProjectMat(fovy, aspect, zNear, zFar);
			setViewMat(eye, lookat, cam_y);
			printCamInfo();
		}

		void camReset()
		{
			fovy = fov_main;
			aspect = aspect_main;
			zNear = mesh_pt->zNear_opt;
			zFar = mesh_pt->zFar_opt;
			setProjectMat(fovy, aspect, zNear, zFar);

			eye = mesh_pt->eye_opt;
			lookat = mesh_pt->lookat_opt;
			cam_x = glm::vec3(1, 0, 0);
			cam_y = glm::vec3(0, 1, 0); //up
			cam_z = glm::vec3(0, 0, 1);
			setViewMat(eye, lookat, cam_y);

			printCamInfo();
		}

	protected:
	private:
};

#endif // CAMERA_INCLUDED_H