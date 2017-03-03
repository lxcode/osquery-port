# Created by: Ryan Steinmetz <zi@FreeBSD.org>
# $FreeBSD: head/sysutils/osquery/Makefile 434689 2017-02-23 22:37:07Z zi $

PORTNAME=	osquery
PORTVERSION=	2.3.4
CATEGORIES=	sysutils

MAINTAINER=	zi@FreeBSD.org
COMMENT=	SQL powered OS instrumentation, monitoring, and analytics

LICENSE=	BSD3CLAUSE
LICENSE_FILE=	${WRKSRC}/LICENSE

BUILD_DEPENDS=	snappy>0:archivers/snappy \
		rocksdb>0:databases/rocksdb \
		thrift>0:devel/thrift \
		thrift-cpp>0:devel/thrift-cpp \
		bash>0:shells/bash \
		yara>0:security/yara \
		glog>0:devel/glog \
		aws-sdk-cpp>0:devel/aws-sdk-cpp \
		linenoise-ng>0:devel/linenoise-ng \
		cpp-netlib>0:devel/cpp-netlib \
		doxygen:devel/doxygen \
		${PYTHON_PKGNAMEPREFIX}MarkupSafe>0:textproc/py-MarkupSafe \
		${PYTHON_PKGNAMEPREFIX}psutil>0:sysutils/py-psutil \
		${PYTHON_PKGNAMEPREFIX}pexpect>0:misc/py-pexpect \
		${PYTHON_PKGNAMEPREFIX}Jinja2>0:devel/py-Jinja2  \
		${PYTHON_PKGNAMEPREFIX}thrift>0:devel/py-thrift \
		${PYTHON_PKGNAMEPREFIX}pip>0:devel/py-pip
LIB_DEPENDS=	libboost_regex.so:devel/boost-libs \
		libgflags.so:devel/gflags \
		libicuuc.so:devel/icu \
		libtsk.so:sysutils/sleuthkit \
		libaugeas.so:textproc/augeas

USES=		cmake:outsource gmake libtool python:build compiler:c++11-lib
CONFIGURE_ENV+=	OSQUERY_BUILD_VERSION="${PORTVERSION}" HOME="${WRKDIR}" \
		SKIP_TESTS="yes" CC="${CC}" CXX="${CXX}"
CMAKE_ARGS+=	-DFREEBSD=awesome -DCMAKE_SYSTEM_NAME="FreeBSD"
BLDDIR=		${WRKDIR}/.build/${PORTNAME}
USE_RC_SUBR=	${PORTNAME}d
USE_GITHUB=	yes
GH_ACCOUNT=	facebook ${PORTNAME}:tp
GH_PROJECT=	third-party:tp
GH_SUBDIR=	third-party:tp
MAKE_JOBS_UNSAFE=	yes

post-patch:
	${REINPLACE_CMD} -e 's|/var/osquery/|/var/db/osquery/|g' \
		${WRKSRC}/tools/deployment/osquery.example.conf
	${REINPLACE_CMD} -e 's|python |${PYTHON_CMD} |g' \
		${WRKSRC}/CMake/CMakeLibs.cmake \
		${WRKSRC}/CMakeLists.txt

do-install:
	${INSTALL_PROGRAM} ${BLDDIR}/osqueryi ${STAGEDIR}${PREFIX}/bin
	${INSTALL_PROGRAM} ${BLDDIR}/osqueryd ${STAGEDIR}${PREFIX}/sbin
	${INSTALL_DATA} ${BLDDIR}/libosquery.a ${STAGEDIR}${PREFIX}/lib
	(cd ${WRKSRC}/include && ${COPYTREE_SHARE} ${PORTNAME} ${STAGEDIR}${PREFIX}/include)
	${INSTALL_DATA} ${WRKSRC}/tools/deployment/osquery.example.conf \
		${STAGEDIR}${PREFIX}/etc/osquery.conf.sample

	${MKDIR} ${STAGEDIR}/var/db/osquery

.include <bsd.port.mk>
