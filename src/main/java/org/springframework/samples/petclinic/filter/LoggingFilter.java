package org.springframework.samples.petclinic.filter;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.MDC;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.UUID;

@Order(1)
@Component
public class LoggingFilter implements Filter {

	private final Logger LOG = LoggerFactory.getLogger(LoggingFilter.class);

	@Override
	public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
			throws IOException, ServletException {
		HttpServletRequest req = (HttpServletRequest) request;
		HttpServletResponse res = (HttpServletResponse) response;

		String HOST_CLIENT_IP = String.format("[Host: %s | Client %s]", req.getLocalAddr(), req.getRemoteAddr());
		MDC.put("HOST_CLIENT_IP", HOST_CLIENT_IP);
		chain.doFilter(request, response);

		String METHOD_STATUS = String.format("%s %s - %s - Status %d", req.getProtocol(), req.getMethod(),
				req.getRequestURI(), res.getStatus());
		LOG.info(METHOD_STATUS);
	}

	@Override
	public void destroy() {
		// TODO Auto-generated method stub

	}

	@Override
	public void init(FilterConfig filterConfig) throws ServletException {
		// TODO Auto-generated method stub

	}

}