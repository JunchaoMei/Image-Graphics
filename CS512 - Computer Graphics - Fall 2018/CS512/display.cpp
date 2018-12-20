#include <GL/glew.h>
#include <GL/freeglut.h>
#include <windows.h>
#include <stdio.h>
#include <iostream>
#include <string>
#include <fstream>
#include <sstream>
#include "mesh.h"
#include "shader.h"
#include "camera.h"

extern GLenum primitive_main;
extern int modelRep;
extern Mesh* mesh_pt;
extern float Red;
extern float Green;
extern float Blue;
extern float Alpha;
extern Camera* camera_pt;
extern int mainWindow, subWin1, subWin2;

#define MAX_CHAR 128 //ASCII字符总共只有0到127，一共128种字符

GLuint vsID, fsID, pID, VBO1, VBO2, VAO, EBO;
GLfloat projectionMat[16], modelViewMat[16];
unsigned int m_drawCount;
bool newFileLoaded;
bool isCounterClockwise = true;
bool isCullBack = true;

//不变参数
GLfloat mat_specularG[4] = { 1.0f, 1.0f, 1.0f, 1.0f };
GLfloat mat_shininessG = 15.0f;
GLfloat light0_positionG[4] = { 3.0f, 3.0f, 3.0f, 1.0f };
GLfloat light0_attenuationG[3] = { 1.0f, 0.002f, 0.001f };
//默认参数 - 可改
GLfloat light0_ambientG[4] = { 0.2f, 0.2f, 0.2f, 1.0f };
GLfloat light0_diffuseG[4] = { 1.0f, 1.0f, 1.0f, 1.0f };
GLfloat light0_specularG[4] = { 1.0f, 1.0f, 1.0f, 1.0f };
GLfloat Light_Model_AmbientG[4] = { 0.2f, 0.2f, 0.2f, 1.0f };
bool lightsOn = true;
bool light0On = true;
bool smoothShading = true;

void drawString(const char* str)
{
	static int isFirstCall = 1;
	static GLuint lists;

	if (isFirstCall)
	{	// 如果是第一次调用，执行初始化, 为每一个ASCII字符产生一个显示列表
		isFirstCall = 0;
		// 申请MAX_CHAR个连续的显示列表编号
		lists = glGenLists(MAX_CHAR);
		// 把每个字符的绘制命令都装到对应的显示列表中
		wglUseFontBitmaps(wglGetCurrentDC(), 0, MAX_CHAR, lists);
	}
	// 调用每个字符对应的显示列表，绘制每个字符
	for (; *str != '\0'; ++str)
		glCallList(lists + *str);
}

void selectFont(int size, int charset, const char* face)
{
	HFONT hFont = CreateFontA(size, 0, 0, 0, FW_MEDIUM, 0, 0, 0,
		charset, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS,
		DEFAULT_QUALITY, DEFAULT_PITCH | FF_SWISS, face);
	HFONT hOldFont = (HFONT)SelectObject(wglGetCurrentDC(), hFont);
	DeleteObject(hOldFont);
}

void displayMain()
{
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	glShadeModel(GL_SMOOTH);
	glLoadIdentity();

	selectFont(30, ANSI_CHARSET, "Calibri");
	glColor3f(1.0f, 0.0f, 1.0f);
	glRasterPos2f(-2.3f, 1.8f);
	drawString("Fixed Pipeline");

	selectFont(30, ANSI_CHARSET, "Calibri");
	glColor3f(0.0f, 1.0f, 1.0f);
	glRasterPos2f(1.4f, 1.8f);
	drawString("Using Shader");

	glFlush();
	glutSwapBuffers();
	glutSetWindow(subWin1);
	displaySub1();
	glutSetWindow(subWin2);
	displaySub2();
	glutSetWindow(mainWindow);
}

void switchPolygonMode(int repre)
{
	switch (repre)
	{
		case 1: //points
			glPolygonMode(GL_FRONT_AND_BACK, GL_POINT);
			break;
		case 2: //wireframe
			glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
			break;
		case 3: //solid
			glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
			break;
	}
}

void switchHandedness()
{
	if (isCounterClockwise)
		glFrontFace(GL_CCW);
	else
		glFrontFace(GL_CW);
}

void swithCulling()
{
	if (isCullBack)
		glCullFace(GL_BACK);
	else
		glCullFace(GL_FRONT);
}

void drawPrimitives(IndexedModel model, GLenum primitive, int repre)
{
	//Viewing & Projection -- fixed pipeline  --  using [glu functions]
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	gluPerspective((GLdouble)camera_pt->fovy, (GLdouble)camera_pt->aspect, (GLdouble)camera_pt->zNear, (GLdouble)camera_pt->zFar);
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	gluLookAt((GLdouble)camera_pt->eye[0], (GLdouble)camera_pt->eye[1], (GLdouble)camera_pt->eye[2], (GLdouble)camera_pt->lookat[0], (GLdouble)camera_pt->lookat[1], (GLdouble)camera_pt->lookat[2], (GLdouble)camera_pt->cam_y[0], (GLdouble)camera_pt->cam_y[1], (GLdouble)camera_pt->cam_y[2]);

	//change handedness
	switchHandedness();
	switchPolygonMode(repre);
	glEnable(GL_CULL_FACE);
	swithCulling();

	glBegin(primitive);
	for (unsigned int i = 0; i < model.indices.size(); i++)
	{
		int j = model.indices[i];
		glm::vec3 nor = model.normals[j];
		GLfloat norm[3] = {nor[0],nor[1],nor[2]};
		glNormal3fv(norm);
		glm::vec3 ver = model.positions[j];
		GLfloat vert[3] = {ver[0],ver[1],ver[2]};
		glVertex3fv(vert);
	}
	glEnd();
}

void setGlobalAmbientLight()
{
	GLfloat Light_Model_Ambient[4] = { Light_Model_AmbientG[0], Light_Model_AmbientG[1], Light_Model_AmbientG[2], Light_Model_AmbientG[3] };
	glLightModelfv(GL_LIGHT_MODEL_AMBIENT, Light_Model_Ambient);
}

void setPointLight()
{
	//材质参数
	GLfloat mat_ambient[4] = { 0.2f*Red, 0.2f*Green, 0.2f*Blue, 1.0f };
	GLfloat mat_diffuse[4] = { 0.8f*Red, 0.8f*Green, 0.8f*Blue, 1.0f };
	//灯光参数
	GLfloat light0_ambient[4] = { light0_ambientG[0], light0_ambientG[1], light0_ambientG[2], light0_ambientG[3] };
	GLfloat light0_diffuse[4] = { light0_diffuseG[0], light0_diffuseG[1], light0_diffuseG[2], light0_diffuseG[3] };
	GLfloat light0_specular[4] = { light0_specularG[0], light0_specularG[1], light0_specularG[2], light0_specularG[3] };

	//参数设置
	glMaterialfv(GL_FRONT, GL_AMBIENT, mat_ambient);
	glMaterialfv(GL_FRONT, GL_DIFFUSE, mat_diffuse);
	glMaterialfv(GL_FRONT, GL_SPECULAR, mat_specularG);
	glMaterialf(GL_FRONT, GL_SHININESS, mat_shininessG);
	glLightfv(GL_LIGHT0, GL_AMBIENT, light0_ambient);
	glLightfv(GL_LIGHT0, GL_DIFFUSE, light0_diffuse);
	glLightfv(GL_LIGHT0, GL_SPECULAR, light0_specular);
	glLightfv(GL_LIGHT0, GL_POSITION, light0_positionG);
	glLightf(GL_LIGHT0, GL_CONSTANT_ATTENUATION, light0_attenuationG[0]);
	glLightf(GL_LIGHT0, GL_LINEAR_ATTENUATION, light0_attenuationG[1]);
	glLightf(GL_LIGHT0, GL_QUADRATIC_ATTENUATION, light0_attenuationG[2]);
}

void displaySub1()
{
	//开关灯
	if (lightsOn)
	{
		setGlobalAmbientLight();
		glEnable(GL_LIGHTING);
	} else
		glDisable(GL_LIGHTING);
	if (light0On)
	{
		setPointLight();
		glEnable(GL_LIGHT0);
	} else
		glDisable(GL_LIGHT0);

	//shading模式
	if (smoothShading)
		glShadeModel(GL_SMOOTH);
	else
		glShadeModel(GL_FLAT);

	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	glEnable(GL_DEPTH_TEST);
	glLoadIdentity();
	glColor3f(Red, Green, Blue);
	drawPrimitives(mesh_pt->model, primitive_main, modelRep);
	glFlush();
	glutSwapBuffers();
}

void printGLfloatArray(GLfloat arr[])
{
	std::cout << "Matrix: ";
	for (int i = 0; i < 16; i++)
	{
		std::cout << arr[i] << "\t";
	}
	std::cout << std::endl;
}

void readShaderFile(const GLchar* shaderPath, std::string& shaderCode)
{
	std::ifstream shaderFile;
	// ensures ifstream objects can throw exceptions:
	shaderFile.exceptions(std::ifstream::badbit);
	try
	{
		// Open files
		shaderFile.open(shaderPath);
		std::stringstream shaderStream;
		// Read file's buffer contents into streams
		shaderStream << shaderFile.rdbuf();
		// close file handlers
		shaderFile.close();
		// Convert stream into GLchar array
		shaderCode = shaderStream.str();
	}
	catch (std::ifstream::failure e)
	{
		std::cout << "ERROR::SHADER::FILE_NOT_SUCCESFULLY_READ" << std::endl;
	}
}

void setShaders()
{
	char *vs = NULL, *fs = NULL;

	vsID = glCreateShader(GL_VERTEX_SHADER);
	fsID = glCreateShader(GL_FRAGMENT_SHADER);

	std::string vertShaderString;
	std::string fragShaderString;
	if (lightsOn)
	{
		if (smoothShading)
		{
			readShaderFile("./res/vertexshader_lightsOn_Smooth.txt", vertShaderString);
			readShaderFile("./res/fragshader_lightsOn__Smooth.txt", fragShaderString);
		} else
		{
			readShaderFile("./res/vertexshader_lightsOn_Flat.txt", vertShaderString);
			readShaderFile("./res/fragshader_lightsOn__Flat.txt", fragShaderString);
		}
	} else
	{
		readShaderFile("./res/vertexshader_lightsOff.txt", vertShaderString);
		fragShaderString = "#version 330 core\n\nvoid main()\n{\ngl_FragColor = vec4(" + std::to_string(Red) + +", " + std::to_string(Green) + ", " + std::to_string(Blue) + ", " + std::to_string(Alpha) + ");\n}";
	}
	const GLchar * pVertShaderSource = vertShaderString.c_str();
	const GLchar * pFragShaderSource = fragShaderString.c_str();
	
	glShaderSource(vsID, 1, &pVertShaderSource, NULL);
	glShaderSource(fsID, 1, &pFragShaderSource, NULL);

	glCompileShader(vsID);
	GLint vsIsCompiled = 0;
	glGetShaderiv(vsID, GL_COMPILE_STATUS, &vsIsCompiled);
	if (vsIsCompiled == GL_FALSE)
	{
		printf("Problem with vertex shader\n");
		GLint maxLength = 0;
		glGetShaderiv(vsID, GL_INFO_LOG_LENGTH, &maxLength);

		//The maxLength includes the NULL character
		std::vector<GLchar> infoLog(maxLength);
		glGetShaderInfoLog(vsID, maxLength, &maxLength, &infoLog[0]);

		// We don't need the shader anymore.
		glDeleteShader(vsID);

		// Use the infoLog as you see fit.
		for (std::vector<char>::const_iterator i = infoLog.begin(); i != infoLog.end(); ++i)
			std::cout << *i;
		return;
	}

	glCompileShader(fsID);
	GLint fsIsCompiled = 0;
	glGetShaderiv(fsID, GL_COMPILE_STATUS, &fsIsCompiled);
	if (fsIsCompiled == GL_FALSE)
	{
		printf("Problem with fragment shader\n");
		GLint maxLength = 0;
		glGetShaderiv(fsID, GL_INFO_LOG_LENGTH, &maxLength);

		//The maxLength includes the NULL character
		std::vector<GLchar> infoLog(maxLength);
		glGetShaderInfoLog(fsID, maxLength, &maxLength, &infoLog[0]);

		// We don't need the shader anymore.
		glDeleteShader(fsID);

		// Use the infoLog as you see fit.
		for (std::vector<char>::const_iterator i = infoLog.begin(); i != infoLog.end(); ++i)
			std::cout << *i;
		return;
	}

	pID = glCreateProgram();
	glAttachShader(pID, vsID);
	glAttachShader(pID, fsID);

	glLinkProgram(pID);
	glUseProgram(pID);

	//=====================Uniform Inputs=======================
	//Viewing & Projection
	GLint modeViewMatLocation = glGetUniformLocation(pID, "modelViewMatrix");
	glUniformMatrix4fv(modeViewMatLocation, 1, GL_FALSE, camera_pt->viewMat);
	GLint projectionMatLocation = glGetUniformLocation(pID, "projectionMatrix");
	glUniformMatrix4fv(projectionMatLocation, 1, GL_FALSE, camera_pt->projectMat);
	GLint camPosLocation = glGetUniformLocation(pID, "cameraPosition");
	GLfloat camPosVec[3] = { camera_pt->eye[0], camera_pt->eye[1], camera_pt->eye[2] };
	glUniform3fv(camPosLocation, 1, camPosVec);
	//Material Parameters
	GLint matAmbLocation = glGetUniformLocation(pID, "materialAmbientReflectances");
	GLfloat mat_ambient[4] = { 0.2f*Red, 0.2f*Green, 0.2f*Blue, 1.0f };
	glUniform4fv(matAmbLocation, 1, mat_ambient);
	GLint matDiffLocation = glGetUniformLocation(pID, "materialDiffuseReflectances");
	GLfloat mat_diffuse[4] = { 0.8f*Red, 0.8f*Green, 0.8f*Blue, 1.0f };
	glUniform4fv(matDiffLocation, 1, mat_diffuse);
	GLint matSpecLocation = glGetUniformLocation(pID, "materialSpecularReflectances");
	glUniform4fv(matSpecLocation, 1, mat_specularG);
	GLint matShineLocation = glGetUniformLocation(pID, "materialShininess");
	glUniform1f(matShineLocation, mat_shininessG);
	//Light Parameters
	GLint lightPosLocation = glGetUniformLocation(pID, "lightPosition");
	GLfloat lightPosVec[3] = { light0_positionG[0], light0_positionG[1], light0_positionG[2] }; // vec4 -> vec3
	glUniform3fv(lightPosLocation, 1, lightPosVec);
	GLfloat lightAmbVec[4], lightDiffVec[4], lightSpecVec[4];
	if (light0On)
	{
		lightAmbVec[0]=light0_ambientG[0]; lightAmbVec[1]=light0_ambientG[1]; lightAmbVec[2]=light0_ambientG[2]; lightAmbVec[3]=light0_ambientG[3];
		lightDiffVec[0]=light0_diffuseG[0]; lightDiffVec[1]=light0_diffuseG[1]; lightDiffVec[2]=light0_diffuseG[2]; lightDiffVec[3]=light0_diffuseG[3];
		lightSpecVec[0]=light0_specularG[0]; lightSpecVec[1]=light0_specularG[1]; lightSpecVec[2]=light0_specularG[2]; lightSpecVec[3]=light0_specularG[3];
	} else
	{
		lightAmbVec[0]=0.0f; lightAmbVec[1]=0.0f; lightAmbVec[2]=0.0f; lightAmbVec[3]=0.0f;
		lightDiffVec[0]=0.0f; lightDiffVec[1]=0.0f; lightDiffVec[2]=0.0f; lightDiffVec[3]=0.0f;
		lightSpecVec[0]=0.0f; lightSpecVec[1]=0.0f; lightSpecVec[2]=0.0f; lightSpecVec[3]=0.0f;
	}
	GLint lightAmbLocation = glGetUniformLocation(pID, "lightAmbientIntensitys");
	glUniform4fv(lightAmbLocation, 1, lightAmbVec);
	GLint lightDiffLocation = glGetUniformLocation(pID, "lightDiffuseIntensitys");
	glUniform4fv(lightDiffLocation, 1, lightDiffVec);
	GLint lightSpecLocation = glGetUniformLocation(pID, "lightSpecularIntensitys");
	glUniform4fv(lightSpecLocation, 1, lightSpecVec);
	GLint globalAmbLocation = glGetUniformLocation(pID, "globalAmbientIntensitys");
	GLfloat globalAmbVec[4] = { Light_Model_AmbientG[0], Light_Model_AmbientG[1], Light_Model_AmbientG[2], Light_Model_AmbientG[3] };
	glUniform4fv(globalAmbLocation, 1, globalAmbVec);
	GLint attenParaLocation = glGetUniformLocation(pID, "attenuationParameters");
	glUniform3fv(attenParaLocation, 1, light0_attenuationG);

	//==========delete shaders=========
	glDeleteShader(vsID);
	glDeleteShader(fsID);
	//std::cout << "setShader() is called!" << std::endl;
}

void initBufferObject(void)
{
	m_drawCount = mesh_pt->model.indices.size();
	//std::cout << m_drawCount << std::endl;

	glGenBuffers(1, &VBO1);
	glGenBuffers(1, &VBO2);
	glGenBuffers(1, &EBO);

	// setup VAO
	glGenVertexArrays(1, &VAO);
	glBindVertexArray(VAO);

	glBindBuffer(GL_ARRAY_BUFFER, VBO1);
	glBufferData(GL_ARRAY_BUFFER, mesh_pt->model.positions.size() * sizeof(mesh_pt->model.positions[0]), &mesh_pt->model.positions[0], GL_STATIC_DRAW);
	glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, 0);
	glEnableVertexAttribArray(0);

	glBindBuffer(GL_ARRAY_BUFFER, VBO2);
	glBufferData(GL_ARRAY_BUFFER, mesh_pt->model.normals.size() * sizeof(mesh_pt->model.normals[0]), &mesh_pt->model.normals[0], GL_STATIC_DRAW);
	glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 0, 0);
	glEnableVertexAttribArray(1);

	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, mesh_pt->model.indices.size() * sizeof(mesh_pt->model.indices[0]), &mesh_pt->model.indices[0], GL_STATIC_DRAW);

	glBindBuffer(GL_ARRAY_BUFFER, 0);
	glBindVertexArray(0);

	// Use depth buffering for hidden surface elimination
	glEnable(GL_DEPTH_TEST);

	// =====test=====
	//printGLfloatArray(projectionMat);
	//printGLfloatArray(modelViewMat);

	/* // setup Color
	color2Shader[0] = (GLfloat)Red;
	color2Shader[1] = (GLfloat)Green;
	color2Shader[2] = (GLfloat)Blue;
	*/
	//std::cout << "initBufferObject() is called!" << std::endl;
}

void updateShader()
{
	if (newFileLoaded)
	{
		initBufferObject();
		newFileLoaded = false;
	}
	setShaders();
}

void displaySub2()
{
	glEnable(GL_DEPTH_TEST);
	updateShader();

	glUseProgram(pID);
	//glUseProgram(0);
	glValidateProgram(pID);
	GLint validate = 0;
	glGetProgramiv(pID, GL_VALIDATE_STATUS, &validate);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	glBindVertexArray(VAO);

	//change handedness
	switchHandedness();
	switchPolygonMode(modelRep);
	glEnable(GL_CULL_FACE);
	swithCulling();

	glDrawElements(primitive_main, m_drawCount, GL_UNSIGNED_INT, 0);
	
	glBindVertexArray(0);
	glFlush();
	glutSwapBuffers();
	//std::cout << "displaySub2() is called!" << std::endl;
}

void reshapeMain(int w, int h)
{
	glViewport(0, 0, w, h);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	//glOrtho(-2.0, 2.0, -2.0, 2.0, -10.0, 10.0);
	if (w <= h)
		glOrtho(-2.0, 2.0, -2.0 * (GLfloat) h / (GLfloat) w, 2.0 * (GLfloat) h / (GLfloat) w, -10.0, 10.0);
	else
		glOrtho(-2.0 * (GLfloat) w / (GLfloat) h, 2.0 * (GLfloat) w / (GLfloat) h, -2.0, 2.0, -10.0, 10.0);
	glMatrixMode(GL_MODELVIEW);
}

void loadNewFile(std::string newObjFile)
{
	std::cout << "Loading " << newObjFile << " ...." << std::endl;
	//=================update the mesh=============================
	OBJModel obj = OBJModel("./res/" + newObjFile);
	mesh_pt->model = obj.ToIndexedModel();
	mesh_pt->x_min = mesh_pt->model.positions[0][0]; mesh_pt->x_max = mesh_pt->model.positions[0][0];
	mesh_pt->y_min = mesh_pt->model.positions[0][1]; mesh_pt->y_max = mesh_pt->model.positions[0][1];
	mesh_pt->z_min = mesh_pt->model.positions[0][2]; mesh_pt->z_max = mesh_pt->model.positions[0][2];
	for (unsigned int i = 0; i < mesh_pt->model.positions.size(); i++)
	{
		mesh_pt->x_min = (mesh_pt->x_min < mesh_pt->model.positions[i][0]) ? mesh_pt->x_min : mesh_pt->model.positions[i][0];
		mesh_pt->x_max = (mesh_pt->x_max > mesh_pt->model.positions[i][0]) ? mesh_pt->x_max : mesh_pt->model.positions[i][0];
		mesh_pt->y_min = (mesh_pt->y_min < mesh_pt->model.positions[i][1]) ? mesh_pt->y_min : mesh_pt->model.positions[i][1];
		mesh_pt->y_max = (mesh_pt->y_max > mesh_pt->model.positions[i][1]) ? mesh_pt->y_max : mesh_pt->model.positions[i][1];
		mesh_pt->z_min = (mesh_pt->z_min < mesh_pt->model.positions[i][2]) ? mesh_pt->z_min : mesh_pt->model.positions[i][2];
		mesh_pt->z_max = (mesh_pt->z_max > mesh_pt->model.positions[i][2]) ? mesh_pt->z_max : mesh_pt->model.positions[i][2];
	}
	double pos_opt_x = (mesh_pt->x_min + mesh_pt->x_max) / 2;
	double pos_opt_y = (mesh_pt->y_min + mesh_pt->y_max) / 2;
	double delta_x = mesh_pt->x_max - mesh_pt->x_min; double delta_y = mesh_pt->y_max - mesh_pt->y_min;
	double dist1 = ((delta_y > delta_x) ? delta_y : delta_x) / sqrt(2);
	double dist2 = (mesh_pt->z_max - mesh_pt->z_min) * 1.4;
	double dist_z = (dist1 > dist2) ? dist1 : dist2;
	double pos_opt_z = mesh_pt->z_max + dist_z;
	mesh_pt->eye_opt = glm::vec3(pos_opt_x, pos_opt_y, pos_opt_z);
	mesh_pt->lookat_opt = glm::vec3(pos_opt_x, pos_opt_y, (mesh_pt->z_min + mesh_pt->z_max) / 2);
	mesh_pt->zNear_opt = float(mesh_pt->z_max + dist_z / 2);
	mesh_pt->zFar_opt = float(mesh_pt->z_min - dist_z * 100);
	//=================finish updating the mesh=============================
	newFileLoaded = true;
	std::cout << newObjFile << " is successfully loaded!" << std::endl;
}

void printMaterialLightConstInfo()
{
	std::cout << std::endl << "[Basic Illumination Settings]" << std::endl;
	std::cout << "Material Specular Reflectances RGBA = { " << mat_specularG[0] << ", " << mat_specularG[1] << ", " << mat_specularG[2] << ", " << mat_specularG[3] << " }" << std::endl;
	std::cout << "Material Shininess: " << mat_shininessG << std::endl;
	std::cout << "Light Source(s): point light #0" << std::endl;
	std::cout << "Light#0 Position: XYZW = { " << light0_positionG[0] << ", " << light0_positionG[1] << ", " << light0_positionG[2] << ", " << light0_positionG[3] << " }" << std::endl;
	std::cout << "Light#0 Attenuation: ABD = { " << light0_attenuationG[0] << ", " << light0_attenuationG[1] << ", " << light0_attenuationG[2] << " }" << std::endl << std::endl;
}

void printColorLightInfo()
{
	std::cout << std::endl << "[Color and Light Settings]" << std::endl;
	std::cout << "Object Intrinsic Color RGBA = { " << Red << ", " << Green << ", " << Blue << ", " << Alpha << " }" << std::endl;
	std::cout << "Global Ambient Light RGBA = { " << Light_Model_AmbientG[0] << ", " << Light_Model_AmbientG[1] << ", " << Light_Model_AmbientG[2] << ", " << Light_Model_AmbientG[3] << " }" << std::endl;
	std::cout << "Light#0 Ambient RGBA = { " << light0_ambientG[0] << ", " << light0_ambientG[1] << ", " << light0_ambientG[2] << ", " << light0_ambientG[3] << " }" << std::endl;
	std::cout << "Light#0 Diffuse RGBA = { " << light0_diffuseG[0] << ", " << light0_diffuseG[1] << ", " << light0_diffuseG[2] << ", " << light0_diffuseG[3] << " }" << std::endl;
	std::cout << "Light#0 Specular RGBA = { " << light0_specularG[0] << ", " << light0_specularG[1] << ", " << light0_specularG[2] << ", " << light0_specularG[3] << " }" << std::endl;
	std::cout << "Lights On: " << lightsOn << std::endl;
	std::cout << "Light#0 On: " << light0On << std::endl << std::endl;
}

void colorMenu(int value)
{
	switch (value)
	{
		case 11: //red
			Red = 1.0; Green = 0.0; Blue = 0.0;
			printColorLightInfo();
			break;
		case 12: //orange
			Red = 1.0; Green = 0.5; Blue = 0.0;
			printColorLightInfo();
			break;
		case 13: //yellow
			Red = 1.0; Green = 1.0; Blue = 0.0;
			printColorLightInfo();
			break;
		case 14: //green
			Red = 0.0; Green = 1.0; Blue = 0.0;
			printColorLightInfo();
			break;
		case 15: //cyan
			Red = 0.0; Green = 1.0; Blue = 1.0;
			printColorLightInfo();
			break;
		case 16: //blue
			Red = 0.0; Green = 0.0; Blue = 1.0;
			printColorLightInfo();
			break;
		case 17: //purple
			Red = 0.5; Green = 0.0; Blue = 1.0;
			printColorLightInfo();
			break;
		case 18: //pink
			Red = 1.0; Green = 0.0; Blue = 1.0;
			printColorLightInfo();
			break;
		case 19: //white
			Red = 1.0; Green = 1.0; Blue = 1.0;
			printColorLightInfo();
			break;
		case 110: //black
			Red = 0.0; Green = 0.0; Blue = 0.0;
			printColorLightInfo();
			break;
	}
}
/*
void primitiveMenu(int value)
{
	switch (value)
	{
		case 201: //points
			primitive_main = GL_POINTS;
			break;
		case 202: //wireframe
			primitive_main = GL_LINES;
			break;
		case 203: //solid polygons
			primitive_main = GL_TRIANGLES;
			break;
	}
}
*/
void repreMenu(int value)
{
	switch (value)
	{
		case 21: //points
			modelRep = 1;
			break;
		case 22: //wireframe
			modelRep = 2;
			break;
		case 23: //solid polygons
			modelRep = 3;
			break;
	}
}

void objFileMenu(int value)
{
	switch (value)
	{
		case 31: //bunny
			loadNewFile("bunny.obj");
			break;
		case 32: //cactus
			loadNewFile("cactus.obj");
			break;
		case 33: //monkey3
			loadNewFile("monkey3.obj");
			break;
	}
}

void camTransMenu(int value)
{
	switch (value)
	{
		case 411: //cam_x
			camera_pt->camTrans('y', 'x');
			break;
		case 412: //cam_y
			camera_pt->camTrans('y', 'y');
			break;
		case 413: //cam_z
			camera_pt->camTrans('y', 'z');
			break;
		case 414: //input axis
			camera_pt->camTrans('n', '?');
			break;
	}
}

void camRotateMenu(int value)
{
	switch (value)
	{
		case 421: //cam_x
			camera_pt->camRotate('y', 'x');
			break;
		case 422: //cam_y
			camera_pt->camRotate('y', 'y');
			break;
		case 423: //cam_z
			camera_pt->camRotate('y', 'z');
			break;
		case 424: //input axis
			camera_pt->camRotate('n', '?');
			break;
	}
}

void camClipMenu(int value)
{
	switch (value)
	{
		case 431: //zNear
			camera_pt->camClip('n');
			break;
		case 432: //zFar
			camera_pt->camClip('f');
			break;
	}
}

void cameraMenu(int value)
{
	switch (value)
	{
		case 44: //reset
			camera_pt->camReset();
			break;
	}
}

void handednessMenu(int value)
{
	switch (value)
	{
		case 51: //顺时针
			isCounterClockwise = false;
			break;
		case 52: //逆时针 -- 默认
			isCounterClockwise = true;
			break;
	}
}

void faceCullingMenu(int value)
{
	switch (value)
	{
		case 61: //正面
			isCullBack = false;
			break;
		case 62: //背面 -- 默认
			isCullBack = true;
			break;
	}
}

void globalAmbRGBMenu(int value)
{
	switch (value)
	{
		case 7110: //dimmed(default)
			Light_Model_AmbientG[0] = 0.2f; Light_Model_AmbientG[1] = 0.2f; Light_Model_AmbientG[2] = 0.2f;
			printColorLightInfo();
			break;
		case 7111: //white
			Light_Model_AmbientG[0] = 1.0f; Light_Model_AmbientG[1] = 1.0f; Light_Model_AmbientG[2] = 1.0f;
			printColorLightInfo();
			break;
		case 7112: //reed
			Light_Model_AmbientG[0] = 1.0f; Light_Model_AmbientG[1] = 0.0f; Light_Model_AmbientG[2] = 0.0f;
			printColorLightInfo();
			break;
		case 7113: //orange
			Light_Model_AmbientG[0] = 1.0f; Light_Model_AmbientG[1] = 0.5f; Light_Model_AmbientG[2] = 0.0f;
			printColorLightInfo();
			break;
		case 7114: //yellow
			Light_Model_AmbientG[0] = 1.0f; Light_Model_AmbientG[1] = 1.0f; Light_Model_AmbientG[2] = 0.0f;
			printColorLightInfo();
			break;
		case 7115: //grreen
			Light_Model_AmbientG[0] = 0.0f; Light_Model_AmbientG[1] = 1.0f; Light_Model_AmbientG[2] = 0.0f;
			printColorLightInfo();
			break;
		case 7116: //cyan
			Light_Model_AmbientG[0] = 0.0f; Light_Model_AmbientG[1] = 1.0f; Light_Model_AmbientG[2] = 1.0f;
			printColorLightInfo();
			break;
		case 7117: //bluue
			Light_Model_AmbientG[0] = 0.0f; Light_Model_AmbientG[1] = 0.0f; Light_Model_AmbientG[2] = 1.0f;
			printColorLightInfo();
			break;
		case 7118: //purple
			Light_Model_AmbientG[0] = 0.5f; Light_Model_AmbientG[1] = 0.0f; Light_Model_AmbientG[2] = 1.0f;
			printColorLightInfo();
			break;
		case 7119: //pink
			Light_Model_AmbientG[0] = 1.0f; Light_Model_AmbientG[1] = 0.0f; Light_Model_AmbientG[2] = 1.0f;
			printColorLightInfo();
			break;
	}
}

void globalAmbAlphaMenu(int value)
{
	switch (value)
	{
		case 7121:
			Light_Model_AmbientG[3] = 0.0f;
			printColorLightInfo();
			break;
		case 7122:
			Light_Model_AmbientG[3] = 0.2f;
			printColorLightInfo();
			break;
		case 7123:
			Light_Model_AmbientG[3] = 0.4f;
			printColorLightInfo();
			break;
		case 7124:
			Light_Model_AmbientG[3] = 0.6f;
			printColorLightInfo();
			break;
		case 7125:
			Light_Model_AmbientG[3] = 0.8f;
			printColorLightInfo();
			break;
		case 7126:
			Light_Model_AmbientG[3] = 1.0f;
			printColorLightInfo();
			break;
	}
}

void pointlightAmbRGBMenu(int value)
{
	switch (value)
	{
		case 72110: //dimmed(default)
			light0_ambientG[0] = 0.2f; light0_ambientG[1] = 0.2f; light0_ambientG[2] = 0.2f;
			printColorLightInfo();
			break;
		case 72111: //white
			light0_ambientG[0] = 1.0f; light0_ambientG[1] = 1.0f; light0_ambientG[2] = 1.0f;
			printColorLightInfo();
			break;
		case 72112: //reed
			light0_ambientG[0] = 1.0f; light0_ambientG[1] = 0.0f; light0_ambientG[2] = 0.0f;
			printColorLightInfo();
			break;
		case 72113: //orange
			light0_ambientG[0] = 1.0f; light0_ambientG[1] = 0.5f; light0_ambientG[2] = 0.0f;
			printColorLightInfo();
			break;
		case 72114: //yellow
			light0_ambientG[0] = 1.0f; light0_ambientG[1] = 1.0f; light0_ambientG[2] = 0.0f;
			printColorLightInfo();
			break;
		case 72115: //grreen
			light0_ambientG[0] = 0.0f; light0_ambientG[1] = 1.0f; light0_ambientG[2] = 0.0f;
			printColorLightInfo();
			break;
		case 72116: //cyan
			light0_ambientG[0] = 0.0f; light0_ambientG[1] = 1.0f; light0_ambientG[2] = 1.0f;
			printColorLightInfo();
			break;
		case 72117: //bluue
			light0_ambientG[0] = 0.0f; light0_ambientG[1] = 0.0f; light0_ambientG[2] = 1.0f;
			printColorLightInfo();
			break;
		case 72118: //purple
			light0_ambientG[0] = 0.5f; light0_ambientG[1] = 0.0f; light0_ambientG[2] = 1.0f;
			printColorLightInfo();
			break;
		case 72119: //pink
			light0_ambientG[0] = 1.0f; light0_ambientG[1] = 0.0f; light0_ambientG[2] = 1.0f;
			printColorLightInfo();
			break;
	}
}

void pointLightAmbAlphaMenu(int value)
{
	switch (value)
	{
		case 72121:
			light0_ambientG[3] = 0.0f;
			printColorLightInfo();
			break;
		case 72122:
			light0_ambientG[3] = 0.2f;
			printColorLightInfo();
			break;
		case 72123:
			light0_ambientG[3] = 0.4f;
			printColorLightInfo();
			break;
		case 72124:
			light0_ambientG[3] = 0.6f;
			printColorLightInfo();
			break;
		case 72125:
			light0_ambientG[3] = 0.8f;
			printColorLightInfo();
			break;
		case 72126:
			light0_ambientG[3] = 1.0f;
			printColorLightInfo();
			break;
	}
}

void pointlightDiffRGBMenu(int value)
{
	switch (value)
	{
		case 72211: //white
			light0_diffuseG[0] = 1.0f; light0_diffuseG[1] = 1.0f; light0_diffuseG[2] = 1.0f;
			printColorLightInfo();
			break;
		case 72212: //reed
			light0_diffuseG[0] = 1.0f; light0_diffuseG[1] = 0.0f; light0_diffuseG[2] = 0.0f;
			printColorLightInfo();
			break;
		case 72213: //orange
			light0_diffuseG[0] = 1.0f; light0_diffuseG[1] = 0.5f; light0_diffuseG[2] = 0.0f;
			printColorLightInfo();
			break;
		case 72214: //yellow
			light0_diffuseG[0] = 1.0f; light0_diffuseG[1] = 1.0f; light0_diffuseG[2] = 0.0f;
			printColorLightInfo();
			break;
		case 72215: //grreen
			light0_diffuseG[0] = 0.0f; light0_diffuseG[1] = 1.0f; light0_diffuseG[2] = 0.0f;
			printColorLightInfo();
			break;
		case 72216: //cyan
			light0_diffuseG[0] = 0.0f; light0_diffuseG[1] = 1.0f; light0_diffuseG[2] = 1.0f;
			printColorLightInfo();
			break;
		case 72217: //bluue
			light0_diffuseG[0] = 0.0f; light0_diffuseG[1] = 0.0f; light0_diffuseG[2] = 1.0f;
			printColorLightInfo();
			break;
		case 72218: //purple
			light0_diffuseG[0] = 0.5f; light0_diffuseG[1] = 0.0f; light0_diffuseG[2] = 1.0f;
			printColorLightInfo();
			break;
		case 72219: //pink
			light0_diffuseG[0] = 1.0f; light0_diffuseG[1] = 0.0f; light0_diffuseG[2] = 1.0f;
			printColorLightInfo();
			break;
	}
}

void pointLightDiffAlphaMenu(int value)
{
	switch (value)
	{
		case 72221:
			light0_diffuseG[3] = 0.0f;
			printColorLightInfo();
			break;
		case 72222:
			light0_diffuseG[3] = 0.2f;
			printColorLightInfo();
			break;
		case 72223:
			light0_diffuseG[3] = 0.4f;
			printColorLightInfo();
			break;
		case 72224:
			light0_diffuseG[3] = 0.6f;
			printColorLightInfo();
			break;
		case 72225:
			light0_diffuseG[3] = 0.8f;
			printColorLightInfo();
			break;
		case 72226:
			light0_diffuseG[3] = 1.0f;
			printColorLightInfo();
			break;
	}
}

void pointlightSpecRGBMenu(int value)
{
	switch (value)
	{
		case 72311: //white
			light0_specularG[0] = 1.0f; light0_specularG[1] = 1.0f; light0_specularG[2] = 1.0f;
			printColorLightInfo();
			break;
		case 72312: //reed
			light0_specularG[0] = 1.0f; light0_specularG[1] = 0.0f; light0_specularG[2] = 0.0f;
			printColorLightInfo();
			break;
		case 72313: //orange
			light0_specularG[0] = 1.0f; light0_specularG[1] = 0.5f; light0_specularG[2] = 0.0f;
			printColorLightInfo();
			break;
		case 72314: //yellow
			light0_specularG[0] = 1.0f; light0_specularG[1] = 1.0f; light0_specularG[2] = 0.0f;
			printColorLightInfo();
			break;
		case 72315: //grreen
			light0_specularG[0] = 0.0f; light0_specularG[1] = 1.0f; light0_specularG[2] = 0.0f;
			printColorLightInfo();
			break;
		case 72316: //cyan
			light0_specularG[0] = 0.0f; light0_specularG[1] = 1.0f; light0_specularG[2] = 1.0f;
			printColorLightInfo();
			break;
		case 72317: //bluue
			light0_specularG[0] = 0.0f; light0_specularG[1] = 0.0f; light0_specularG[2] = 1.0f;
			printColorLightInfo();
			break;
		case 72318: //purple
			light0_specularG[0] = 0.5f; light0_specularG[1] = 0.0f; light0_specularG[2] = 1.0f;
			printColorLightInfo();
			break;
		case 72319: //pink
			light0_specularG[0] = 1.0f; light0_specularG[1] = 0.0f; light0_specularG[2] = 1.0f;
			printColorLightInfo();
			break;
	}
}

void pointLightSpecAlphaMenu(int value)
{
	switch (value)
	{
		case 72321:
			light0_specularG[3] = 0.0f;
			printColorLightInfo();
			break;
		case 72322:
			light0_specularG[3] = 0.2f;
			printColorLightInfo();
			break;
		case 72323:
			light0_specularG[3] = 0.4f;
			printColorLightInfo();
			break;
		case 72324:
			light0_specularG[3] = 0.6f;
			printColorLightInfo();
			break;
		case 72325:
			light0_specularG[3] = 0.8f;
			printColorLightInfo();
			break;
		case 72326:
			light0_specularG[3] = 1.0f;
			printColorLightInfo();
			break;
	}
}

void pointLightMenu(int value)
{
	switch (value)
	{
		case 724:
			light0On = !light0On;
			printColorLightInfo();
			break;
	}
}

void lightMenu(int value)
{
	switch (value)
	{
		case 73:
			lightsOn = !lightsOn;
			printColorLightInfo();
			break;
	}
}

void shadingMenu(int value)
{
	switch (value)
	{
		case 81:
			smoothShading = false;
			break;
		case 82:
			smoothShading = true;
			break;
	}
}

void emptyMenu(int value) { }

void mainMenu(int value)
{
	switch (value)
	{
		case 0:
			exit(0);
			break;
	}
}

void createMenu()
{
	int color = glutCreateMenu(colorMenu);
	glutAddMenuEntry("White(default)", 19);
	glutAddMenuEntry("Red", 11);
	glutAddMenuEntry("Orange", 12);
	glutAddMenuEntry("Yellow", 13);
	glutAddMenuEntry("Green", 14);
	glutAddMenuEntry("Cyan", 15);
	glutAddMenuEntry("Blue", 16);
	glutAddMenuEntry("Purple", 17);
	glutAddMenuEntry("Pink", 18);
	glutAddMenuEntry("Black", 110);
	/*
	int primitive = glutCreateMenu(primitiveMenu);
	glutAddMenuEntry("Points", 201);
	glutAddMenuEntry("Wireframe", 202);
	glutAddMenuEntry("Solid", 203);
	*/
	int representing = glutCreateMenu(repreMenu);
	glutAddMenuEntry("Points", 21);
	glutAddMenuEntry("Wireframe", 22);
	glutAddMenuEntry("Solid", 23);

	int objFile = glutCreateMenu(objFileMenu);
	glutAddMenuEntry("bunny", 31);
	glutAddMenuEntry("cactus", 32);
	glutAddMenuEntry("monkey", 33);

	//=========camera start==========
	int camTrans = glutCreateMenu(camTransMenu);
	glutAddMenuEntry("along Cam-X", 411);
	glutAddMenuEntry("along Cam-Y", 412);
	glutAddMenuEntry("along Cam-Z", 413);
	glutAddMenuEntry("customized axis", 414);

	int camRotate = glutCreateMenu(camRotateMenu);
	glutAddMenuEntry("along Cam-X", 421);
	glutAddMenuEntry("along Cam-Y", 422);
	glutAddMenuEntry("along Cam-Z", 423);
	glutAddMenuEntry("customized axis", 424);

	int camClip = glutCreateMenu(camClipMenu);
	glutAddMenuEntry("near", 431);
	glutAddMenuEntry("far", 432);

	int camera = glutCreateMenu(cameraMenu);
	glutAddSubMenu("Translation", camTrans);
	glutAddSubMenu("Rotation", camRotate);
	glutAddSubMenu("Clipping Planes", camClip);
	glutAddMenuEntry("reset", 44);
	//=========camera end==========

	int handedness = glutCreateMenu(handednessMenu);
	glutAddMenuEntry("clockwise", 51);
	glutAddMenuEntry("counter clockwise (default)", 52);

	int faceCulling = glutCreateMenu(faceCullingMenu);
	glutAddMenuEntry("front", 61);
	glutAddMenuEntry("back (default)", 62);
	
	//==========lighting start==========
	//----------------Global Ambient Light (start)---------------
	int globalAmbRGB = glutCreateMenu(globalAmbRGBMenu);
	glutAddMenuEntry("white", 7111);
	glutAddMenuEntry("red", 7112);
	glutAddMenuEntry("orange", 7113);
	glutAddMenuEntry("yellow", 7114);
	glutAddMenuEntry("green", 7115);
	glutAddMenuEntry("cyan", 7116);
	glutAddMenuEntry("blue", 7117);
	glutAddMenuEntry("purple", 7118);
	glutAddMenuEntry("pink", 7119);
	glutAddMenuEntry("dimmed(default)", 7110);

	int globalAmbAlpha = glutCreateMenu(globalAmbAlphaMenu);
	glutAddMenuEntry("0.0", 7121);
	glutAddMenuEntry("0.2", 7122);
	glutAddMenuEntry("0.4", 7123);
	glutAddMenuEntry("0.6", 7124);
	glutAddMenuEntry("0.8", 7125);
	glutAddMenuEntry("1.0(default)", 7126);

	int globalAmb = glutCreateMenu(emptyMenu);
	glutAddSubMenu("RGB", globalAmbRGB);
	glutAddSubMenu("Alpha", globalAmbAlpha);
	//----------------Global Ambient Light (end)---------------
	//----------------Point Light (start)---------------
	//.............point light ambient (start)..............
	int pointLightAmbRGB = glutCreateMenu(pointlightAmbRGBMenu);
	glutAddMenuEntry("white", 72111);
	glutAddMenuEntry("red", 72112);
	glutAddMenuEntry("orange", 72113);
	glutAddMenuEntry("yellow", 72114);
	glutAddMenuEntry("green", 72115);
	glutAddMenuEntry("cyan", 72116);
	glutAddMenuEntry("blue", 72117);
	glutAddMenuEntry("purple", 72118);
	glutAddMenuEntry("pink", 72119);
	glutAddMenuEntry("dimmed(default)", 72110);

	int pointLightAmbAlpha = glutCreateMenu(pointLightAmbAlphaMenu);
	glutAddMenuEntry("0.0", 72121);
	glutAddMenuEntry("0.2", 72122);
	glutAddMenuEntry("0.4", 72123);
	glutAddMenuEntry("0.6", 72124);
	glutAddMenuEntry("0.8", 72125);
	glutAddMenuEntry("1.0(default)", 72126);

	int pointLightAmb = glutCreateMenu(emptyMenu);
	glutAddSubMenu("RGB", pointLightAmbRGB);
	glutAddSubMenu("Alpha", pointLightAmbAlpha);
	//.............point light ambient (end)..............
	//.............point light diffuse (start)..............
	int pointLightDiffRGB = glutCreateMenu(pointlightDiffRGBMenu);
	glutAddMenuEntry("white(default)", 72211);
	glutAddMenuEntry("red", 72212);
	glutAddMenuEntry("orange", 72213);
	glutAddMenuEntry("yellow", 72214);
	glutAddMenuEntry("green", 72215);
	glutAddMenuEntry("cyan", 72216);
	glutAddMenuEntry("blue", 72217);
	glutAddMenuEntry("purple", 72218);
	glutAddMenuEntry("pink", 72219);

	int pointLightDiffAlpha = glutCreateMenu(pointLightDiffAlphaMenu);
	glutAddMenuEntry("0.0", 72221);
	glutAddMenuEntry("0.2", 72222);
	glutAddMenuEntry("0.4", 72223);
	glutAddMenuEntry("0.6", 72224);
	glutAddMenuEntry("0.8", 72225);
	glutAddMenuEntry("1.0(default)", 72226);

	int pointLightDiff = glutCreateMenu(emptyMenu);
	glutAddSubMenu("RGB", pointLightDiffRGB);
	glutAddSubMenu("Alpha", pointLightDiffAlpha);
	//.............point light diffuse (end)..............
	//.............point light specular (start)..............
	int pointLightSpecRGB = glutCreateMenu(pointlightSpecRGBMenu);
	glutAddMenuEntry("white(default)", 72311);
	glutAddMenuEntry("red", 72312);
	glutAddMenuEntry("orange", 72313);
	glutAddMenuEntry("yellow", 72314);
	glutAddMenuEntry("green", 72315);
	glutAddMenuEntry("cyan", 72316);
	glutAddMenuEntry("blue", 72317);
	glutAddMenuEntry("purple", 72318);
	glutAddMenuEntry("pink", 72319);

	int pointLightSpecAlpha = glutCreateMenu(pointLightSpecAlphaMenu);
	glutAddMenuEntry("0.0", 72321);
	glutAddMenuEntry("0.2", 72322);
	glutAddMenuEntry("0.4", 72323);
	glutAddMenuEntry("0.6", 72324);
	glutAddMenuEntry("0.8", 72325);
	glutAddMenuEntry("1.0(default)", 72326);

	int pointLightSpec = glutCreateMenu(emptyMenu);
	glutAddSubMenu("RGB", pointLightSpecRGB);
	glutAddSubMenu("Alpha", pointLightSpecAlpha);
	//.............point light specular (end)..............
	int pointLight = glutCreateMenu(pointLightMenu);
	glutAddSubMenu("Ambient", pointLightAmb);
	glutAddSubMenu("Diffuse", pointLightDiff);
	glutAddSubMenu("Specular", pointLightSpec);
	glutAddMenuEntry("On-Off", 724);
	//----------------Point Light (end)---------------
	int light = glutCreateMenu(lightMenu);
	glutAddSubMenu("Global Ambient Light", globalAmb);
	glutAddSubMenu("Point Light", pointLight);
	glutAddMenuEntry("On-Off", 73);
	//=================lighting end=================

	int shading = glutCreateMenu(shadingMenu);
	glutAddMenuEntry("Flat Shading", 81);
	glutAddMenuEntry("Gouraud Shading", 82);
	
	//=============根菜单 start============
	glutCreateMenu(mainMenu);
	glutAddSubMenu("Color", color);
	//glutAddSubMenu("Primitives", primitive);
	glutAddSubMenu("Represent", representing);
	glutAddSubMenu("Camera", camera);
	glutAddSubMenu("Handedness", handedness);
	glutAddSubMenu("Face Culling", faceCulling);
	glutAddSubMenu("Lighting", light);
	glutAddSubMenu("Shading", shading);
	glutAddSubMenu("Load file", objFile);
	glutAddMenuEntry("Exit", 0);
	glutAttachMenu(GLUT_RIGHT_BUTTON);
	//=============根菜单 end============
}