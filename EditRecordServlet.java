/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.moonbae.servlet;

import com.moonbae.dao.PeriodLogDAO;
import com.moonbae.model.PeriodLog;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Date;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 *
 * @author ASUS
 */
public class EditRecordServlet extends HttpServlet {

    private final PeriodLogDAO logDAO = new PeriodLogDAO();
    
    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet EditRecordServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet EditRecordServlet at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userID") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        try {
            int userID = (int) session.getAttribute("userID");
            int dataID = Integer.parseInt(request.getParameter("dataID"));
            
            String startDateStr = request.getParameter("startDate");
            String endDateStr = request.getParameter("endDate");
            String bloodFlow = request.getParameter("bloodFlow");
            
            // Satukan simptom jadi CSV string
            String[] symptomsArr = request.getParameterValues("symptoms");
            String symptoms = (symptomsArr != null) ? String.join(",", symptomsArr) : "";
            String notes = request.getParameter("notes");

            PeriodLog log = new PeriodLog();
            log.setDataID(dataID);
            log.setUserID(userID);
            log.setStartDate(java.sql.Date.valueOf(startDateStr));
            log.setEndDate(java.sql.Date.valueOf(endDateStr));
            log.setBloodFlowType(bloodFlow);
            log.setSymptoms(symptoms);
            log.setNotes(notes);
            
            boolean success = logDAO.updateLog(log);
            if (success) {
                response.sendRedirect(request.getContextPath() + "/history");
            } else {
                response.sendRedirect(request.getContextPath() + "/history?error=update_failed");
            }
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/history?error=invalid_data");
        }
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
